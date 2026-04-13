import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import '../../generated/l10n.dart';

class LanguageSettingPage extends StatefulWidget {
  const LanguageSettingPage({super.key});

  @override
  LanguageSettingPageState createState() => LanguageSettingPageState();
}

class LanguageSettingPageState extends State<LanguageSettingPage> {
  List<String> languageList = [
    '中文',
    'English',
  ];
  dynamic localizedStrings;

  TextEditingController languageCtl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
    if (localizedStrings.gLanguage == 'Chinese') {
      languageCtl.text = 'English';
    } else if ((localizedStrings.gLanguage == 'Русский')) {
      languageCtl.text = 'Русский';
    } else if (localizedStrings.gLanguage == '中文') {
      languageCtl.text = '中文';
    } else {
      languageCtl.text = 'English';
    }
  }


  void saveLanguageSetting(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedLanguage = prefs.getString('language') ?? '';
    if (savedLanguage == language) {
      return;
    }
    await prefs.setString('language', language);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    languageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 350,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            ...getCustomDialogTitle(
                context, localizedStrings.gTitleLanguageSetting),
            Expanded(
                child: Container(
                    padding: EdgeInsets.all(40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceTint),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 400,
                          child: Text(
                            localizedStrings.gTipSelectLanguage,
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          height: regularPadding,
                        ),
                        SizedBox(
                            width: 400,
                            child: showDropDownButton(
                              context,
                              '',
                              languageCtl,
                              languageList,
                              _changed,
                            )),
                      ],
                    ))),
            showTextButton(context, btnHeight, localizedStrings.gBtnConfirm,
                () async {
              String value = languageCtl.text;
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String savedLanguage = prefs.getString('language') ?? '';
              String language = '';

              setState(() {
                if (value == "中文") {
                  S.load(const Locale('zh', 'CN'));
                  language = 'zh_CN';
                  saveLanguageSetting(language);
                } else if (value == "English") {
                  S.load(const Locale('en', 'US'));
                  language = 'en_US';
                  saveLanguageSetting(language);
                }

                // else if (value == "Русский") {
                //   S.load(const Locale('ru', 'RU'));
                //   saveLanguageSetting('ru_RU');
                // } else if (value == "日本語") {
                //   S.load(const Locale('ja', 'JP'));
                //   saveLanguageSetting('ja_JP');
                // } else if (value == "Italiano") {
                //   S.load(const Locale('it', 'IT'));
                //   saveLanguageSetting('it_IT');
                // } else if (value == "Português") {
                //   S.load(const Locale('pt', 'PT'));
                //   saveLanguageSetting('pt_PT');
                // } else if (value == "Français") {
                //   S.load(const Locale('fr', 'FR'));
                //   saveLanguageSetting('fr_FR');
                // }
              });

              bool isChanged = savedLanguage != language;

              if (!context.mounted) return;
              Navigator.pop(context, isChanged);
            },
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary),
            SizedBox(
              height: regularPadding,
            )
          ],
        ),
      ),
    );
  }

  void _changed(value) {
    if (value != null) {
      languageCtl.text = value;
      // SpUtil.putString(SpConstant.LANGUAGE, value);
      // setState(() {
      //   if (value == "中文") {
      //     S.load(const Locale('zh', 'CN'));
      //     saveLanguageSetting('zh_CN');
      //   } else if (value == "English") {
      //     S.load(const Locale('en', 'US'));
      //     saveLanguageSetting('en_US');
      //   } else if (value == "Русский") {
      //     S.load(const Locale('ru', 'RU'));
      //     saveLanguageSetting('ru_RU');
      //   } else if (value == "日本語") {
      //     S.load(const Locale('ja', 'JP'));
      //     saveLanguageSetting('ja_JP');
      //   } else if (value == "Italiano") {
      //     S.load(const Locale('it', 'IT'));
      //     saveLanguageSetting('it_IT');
      //   } else if (value == "Português") {
      //     S.load(const Locale('pt', 'PT'));
      //     saveLanguageSetting('pt_PT');
      //   } else if (value == "Français") {
      //     S.load(const Locale('fr', 'FR'));
      //     saveLanguageSetting('fr_FR');
      //   }
      // });
    }
  }
}
