//显示认证结果
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/widget/dialog_head_style.dart';

class ShowAppActiveInfo {
  String date;
  String desp;

  ShowAppActiveInfo(this.date, this.desp);
}

class ShowLicenseResDialog extends StatefulWidget {
  final ValueNotifier<Map<String, ShowAppActiveInfo>> mapActiveMenusRes;

  const ShowLicenseResDialog({
    super.key,
    required this.mapActiveMenusRes,
  });

  @override
  ShowLicenseResDialogState createState() => ShowLicenseResDialogState();
}

class ShowLicenseResDialogState extends State<ShowLicenseResDialog> {
  String getPageName(String name) {
    String res = "";

    switch (name) {
      case tConfigLic:
        return (localizedStrings?.gTipAllConfigFunctions ?? "gTipAllConfigFunctions");
      case redeLic:
        return (localizedStrings?.menuReceiptDesign ?? "menuReceiptDesign");
      case wedaLic:
        return (localizedStrings?.menuWeighingDataCollection ?? "menuWeighingDataCollection");
      case chweLic:
        return (localizedStrings?.menuCheckWeighing ?? "menuCheckWeighing");
      case inweLic:
        return (localizedStrings?.menuIncrementWeighing ?? "menuIncrementWeighing");
      case taouLic:
        return (localizedStrings?.menuTakeOutScale ?? "menuTakeOutScale");
      case faspLic:
        return (localizedStrings?.menuFlowRate ?? "menuFlowRate");
      case foscLic:
        return (localizedStrings?.menuFormula ?? "menuFormula");
      case ladeLic:
        return (localizedStrings?.menuLabelDesign ?? "menuLabelDesign");
      default:
        return res;
    }
  }

  Widget errorLicense(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/licenseError.png',
            width: 110.0,
            height: 110.0,
          ),
          const SizedBox(
            height: regularPadding,
          ),
          Text(
            (localizedStrings?.gTipActivationFileError ?? "gTipActivationFileError"),
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .apply(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 638,
        height: 388,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            ...dialogHeadStyle(
              context,
              (localizedStrings?.gTitleActivationFeedback ?? "gTitleActivationFeedback"),
              true,
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(
                  top: regularPadding,
                  bottom: largePadding,
                  left: largePadding,
                  right: largePadding),
              child: ValueListenableBuilder<Map<String, ShowAppActiveInfo>>(
                valueListenable: widget.mapActiveMenusRes,
                builder: (context, value, child) {
                  // 在这里根据 mapActiveMenusRes 的值构建对话框内容
                  List<Widget> children = [];

                  value.forEach((key, info) {
                    children.add(Container(
                      height: inputHeight + smallPadding,
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(children: [
                        SizedBox(
                            height: inputHeight,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: regularPadding,
                                            right: regularPadding),
                                        child: Text(
                                          getPageName(key),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .apply(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                  Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: regularPadding,
                                            right: regularPadding),
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          info.date == '2299-01-01'
                                              ? (localizedStrings?.gTipPerpetual ?? "gTipPerpetual")
                                              : '${info.date} ${info.desp}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .apply(
                                                  color: info.desp
                                                              .contains('ok') ||
                                                          info.date ==
                                                              '2299-01-01'
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .onTertiaryFixedVariant
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .error),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                ])),
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          height: smallPadding,
                        )
                      ]),
                    ));
                  });
                  if (children.isEmpty) {
                    return errorLicense(context);
                  } else {
                    return ListView(
                      children: children,
                    );
                  }
                },
              ),
            )),
            Container(
              height: bottomBtnHeight,
              padding: const EdgeInsets.only(bottom: largePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          fixedSize: const Size(double.infinity, inputHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                          style: Theme.of(context).textTheme.bodyMedium?.apply(
                              color: Theme.of(context).colorScheme.onPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
