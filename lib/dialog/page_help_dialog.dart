import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import '../data/help_data.dart';
import '../data/language.dart';
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
          width: 610,
          height: 500,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(children: [
            ...getCustomDialogTitle(context, (localizedStrings?.gTipHelp ?? "gTipHelp")),
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(
                  left: largePadding, right: largePadding),
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: RichText(
                      text: TextSpan(
                        children: TextUtils.generateTextSpans(
                            context,
                            widget.helpInfo,
                            Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ])),
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
