import 'package:flutter/material.dart';
import 'package:t_max/data/language.dart';

class MobileCheckCodeDialog extends StatefulWidget {
  final String title;
  final String rawId;
  final String rawName;
  final String rawCode;
  final bool canSave;

  const MobileCheckCodeDialog({
    super.key,
    required this.title,
    required this.rawId,
    required this.rawName,
    required this.rawCode,
    required this.canSave,
  });

  @override
  State<MobileCheckCodeDialog> createState() => _MobileCheckCodeDialogState();
}

class _MobileCheckCodeDialogState extends State<MobileCheckCodeDialog> {
  final TextEditingController _checkCodeCtl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _checkCodeCtl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _verifyCode(String val) {
    if (val.isNotEmpty && val == widget.rawCode) {
      Navigator.pop(context, "ok");
    }
  }

  void _submitCode(String val) {
    if (val.isNotEmpty && val == widget.rawCode) {
      Navigator.pop(context, "ok");
    } else {
      setState(() {
        _errorText = localizedStrings?.verificationCodeMismatch ?? "verificationCodeMismatch";
        _checkCodeCtl.clear();
        _focusNode.requestFocus();
      });
    }
  }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title.isNotEmpty
                      ? widget.title
                      : (localizedStrings?.ingredientVerification ?? 'Ingredient Verification'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context, null),
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
            const SizedBox(height: 16),

            // Sub-header Row: Big Raw Name + Ingredient ID + Settings Gear Icon ⚙
            Row(
              children: [
                Text(
                  widget.rawName.isNotEmpty ? widget.rawName : '01',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004884),
                  ),
                ),
                const Spacer(),
                Text(
                  '${localizedStrings?.fMaterialIdCol ?? "Ingredient ID"}: ${widget.rawId}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.black87, size: 22),
                  onPressed: () => Navigator.pop(context, "set"),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: localizedStrings?.gParameterSettingsTitle ?? 'Parameter settings',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Verification Code Label & Field
            Text(
              localizedStrings?.fMaterialCodeCol ?? 'Verification Code',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _errorText.isNotEmpty ? Colors.red : Colors.grey.shade300,
                ),
              ),
              child: TextField(
                controller: _checkCodeCtl,
                focusNode: _focusNode,
                autofocus: true,
                onChanged: _verifyCode,
                onSubmitted: _submitCode,
                decoration: InputDecoration(
                  hintText: localizedStrings?.fMaterialCodeCol ?? 'Verification Code',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            if (_errorText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _errorText,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),

            // Action Buttons
            // Row 1: Skip Ingredient | Abandon
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, "skip"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4D4F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        localizedStrings?.btnSkipRaw ?? 'Skip Ingredient',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, "abandon"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4D4F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        localizedStrings?.fAbandonIngredientsBtn ?? 'Abandon',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Temporary Save
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: widget.canSave ? () => Navigator.pop(context, "save") : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004884),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  localizedStrings?.btnTemporarySave ?? 'Temporary Save',
                  style: const TextStyle(
                    fontSize: 14,
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
