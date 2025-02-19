import 'package:flutter/material.dart';
import 'package:t_max/data/license_data.dart';
import '../data/help_data.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import '../widget/custom_button.dart';
import '../widget/version.dart';

class PageHelpInfoDialog extends StatefulWidget {
  final String helpInfo;

  const PageHelpInfoDialog({required this.helpInfo, super.key});

  @override
  PageHelpInfoDialogState createState() => PageHelpInfoDialogState();
}

class PageHelpInfoDialogState extends State<PageHelpInfoDialog> {
  bool isPass = false;

  Future<void> setAppInfo() async {
    await openAppJson();
  }

  @override
  void initState() {
    super.initState();

    setAppInfo().then((value) => setState(() {}));

    isPass = myLicenseInfo.isValid;
    //初始化
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: getDialogTitle(
          context, localizedStrings.gTipHelp, Icons.help_outlined, 400),
      content: Container(
        height: 500,
        width: 600,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: RichText(
                text: TextSpan(
                  children: TextUtils.generateTextSpans(
                      widget.helpInfo, Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 20),
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.exit_to_app,
              text: localizedStrings.gBtnExit,
              onPressed: () {
                myScreenMgr.isMainScreen = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }

  Widget rightInfoText(String textStr) {
    return SizedBox(
      width: 240,
      child: Text(textStr,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          )),
    );
  }

  Widget leftInfoText(String textStr) {
    return SizedBox(
      width: 150,
      child: Text(textStr,
          textAlign: TextAlign.right,
          overflow: TextOverflow.visible,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          )),
    );
  }
}
