import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/license_data.dart';
import '../data/company_info.dart';
import '../data/language.dart';
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 350,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: ListView(
          children: [
            Container(
                height: dialogTitleheight,
                padding: const EdgeInsets.only(
                    left: largePadding, right: largePadding),
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: regularPadding,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        (localizedStrings?.gAppInformation ?? "gAppInformation"),
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeightDelta: 2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ])),
            // 分割线
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.surfaceContainerLow,
            ),

            const SizedBox(
              height: largePadding,
            ),
            showItemInfo((localizedStrings?.appVersionTitle ?? "appVersionTitle"), getVersion()),
            const SizedBox(
              height: regularPadding,
            ),
            showItemInfo(
                (localizedStrings?.appCompanyTitle ?? "appCompanyTitle"), myCompanyInfo.companyName!),
            const SizedBox(
              height: regularPadding,
            ),
            showItemInfo((localizedStrings?.appTelTitle ?? "appTelTitle"), myCompanyInfo.tel!),
            const SizedBox(
              height: regularPadding,
            ),
            showItemInfo((localizedStrings?.appEmailTitle ?? "appEmailTitle"), myCompanyInfo.email!),
            const SizedBox(
              height: regularPadding,
            ),
            showItemInfo(
                (localizedStrings?.appAddressTitle ?? "appAddressTitle"), myCompanyInfo.address!),
            const SizedBox(
              height: regularPadding,
            ),
            showItemInfo((localizedStrings?.appWebTitle ?? "appWebTitle"), myCompanyInfo.website!),
            const SizedBox(
              height: regularPadding,
            ),
            // showItemInfo((localizedStrings?.appModels ?? "appModels"), "T-Max Series")
          ],
        ),
      ),
    );
  }

  Widget showItemInfo(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: largePadding),
        SizedBox(child: leftInfoText("$title:")),
        SizedBox(
          width: largePadding,
        ),
        Expanded(
          child: rightInfoText(value),
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
        child: Text(
      textStr,
      textAlign: TextAlign.right,
      overflow: TextOverflow.visible,
      style: Theme.of(context).textTheme.bodySmall!.apply(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    ));
  }
}
