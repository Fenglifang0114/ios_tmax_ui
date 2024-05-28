import 'package:flutter/material.dart';

import 'package:t_max/data/license_data.dart';

import '../../generated/l10n.dart';
import '../data/company_info.dart';
import '../data/screen_mgr.dart';
import '../data/setting_version_info.dart';
import '../widget/version.dart';

class CompanyInfoDialog extends StatefulWidget {
  const CompanyInfoDialog({super.key});

  @override
  _CompanyInfoDialogState createState() => _CompanyInfoDialogState();
}

class _CompanyInfoDialogState extends State<CompanyInfoDialog> {
  bool isPass = false;
  dynamic localizedStrings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

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
      title: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.onPrimary),
            Text(
              localizedStrings.about_title,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            )
          ],
        ),
      ),
      content: Container(
        height: 300,
        width: 400,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.onPrimary),
        child: ListView(
          children: [
            Center(
              child: Text(
                mySystemVersionInfo.getTitle(mySystemVersion),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 40),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftInfoText(localizedStrings.app_version_title),
                const SizedBox(
                  width: 10,
                ),
                rightInfoText(getVersion()),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftInfoText(localizedStrings.app_company_title),
                const SizedBox(
                  width: 10,
                ),
                rightInfoText(myCompanyInfo.companyName!),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftInfoText(localizedStrings.app_tel_title),
                const SizedBox(
                  width: 10,
                ),
                rightInfoText(myCompanyInfo.tel!),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftInfoText(localizedStrings.app_email_title),
                const SizedBox(
                  width: 10,
                ),
                rightInfoText(myCompanyInfo.email!),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftInfoText(localizedStrings.app_address_title),
                const SizedBox(
                  width: 10,
                ),
                rightInfoText(myCompanyInfo.address!),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftInfoText(localizedStrings.app_web_title),
                const SizedBox(
                  width: 10,
                ),
                rightInfoText(myCompanyInfo.website!),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftInfoText(localizedStrings.app_models),
                const SizedBox(
                  width: 10,
                ),
                rightInfoText("T-Max Series"),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 20),
            OutlinedButton(
              child: Text(localizedStrings.button_exit),
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
            color: Theme.of(context).colorScheme.onBackground,
          )),
    );
  }
}
