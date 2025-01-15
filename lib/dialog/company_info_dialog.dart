import 'package:flutter/material.dart';
import 'package:t_max/data/license_data.dart';
import '../data/company_info.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import '../widget/custom_button.dart';
import '../widget/version.dart';

class CompanyInfoDialog extends StatefulWidget {
  const CompanyInfoDialog({super.key});

  @override
  CompanyInfoDialogState createState() => CompanyInfoDialogState();
}

class CompanyInfoDialogState extends State<CompanyInfoDialog> {
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
          context, localizedStrings.about_title, Icons.info_outline, 400),
      content: Container(
        height: 300,
        width: 400,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
        child: ListView(
          children: [
            Center(
              child: Text(
                myAppName.appName!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 40),
              ),
            ),
            const SizedBox(
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
