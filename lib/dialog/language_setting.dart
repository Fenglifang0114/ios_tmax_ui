import 'package:flutter/material.dart';
import 'package:t_max/widget/t_max_dialog.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import '../../generated/l10n.dart';
import 'package:t_max/functions/adaptive.dart';

class LanguageSettingPage extends StatefulWidget {
  const LanguageSettingPage({super.key});

  @override
  LanguageSettingPageState createState() => LanguageSettingPageState();
}

class LanguageSettingPageState extends State<LanguageSettingPage> {
  List<String> languageList = [
    '涓枃',
    'English',
  ];
  dynamic localizedStrings;

  TextEditingController languageCtl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
    if ((localizedStrings?.gLanguage ?? "gLanguage") == 'Chinese') {
      languageCtl.text = 'English';
    } else if (((localizedStrings?.gLanguage ?? "gLanguage") == '袪褍褋褋泻懈泄')) {
      languageCtl.text = '袪褍褋褋泻懈泄';
    } else if ((localizedStrings?.gLanguage ?? "gLanguage") == '涓枃') {
      languageCtl.text = '涓枃';
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
    final bool isMobile = Adaptive.isMobile(context);

    if (isMobile) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            title: Text((localizedStrings?.gTitleLanguageSetting ?? "Set Language"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: languageList.length,
                  itemBuilder: (context, index) {
                    final lang = languageList[index];
                    final isSelected = languageCtl.text == lang;
                    return Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(lang, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                            onTap: () {
                              setState(() {
                                languageCtl.text = lang;
                              });
                            }
                          ),
                          if (index < languageList.length - 1)
                            const Divider(height: 1, indent: 16),
                        ]
                      )
                    );
                  }
                )
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: ElevatedButton(
                  onPressed: () async {
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
                    });

                    bool isChanged = savedLanguage != language;
                    if (!context.mounted) return;
                    Navigator.pop(context, isChanged);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: Text((localizedStrings?.gBtnConfirm ?? "Confirm"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                )
              )
            ]
          )
        )
      );
    }

    return TMaxDialog(
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
                context, (localizedStrings?.gTitleLanguageSetting ?? "gTitleLanguageSetting")),
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
                            (localizedStrings?.gTipSelectLanguage ?? "gTipSelectLanguage"),
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
            showTextButton(context, btnHeight, (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                () async {
              String value = languageCtl.text;
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String savedLanguage = prefs.getString('language') ?? '';
              String language = '';

              setState(() {
                if (value == "涓枃") {
                  S.load(const Locale('zh', 'CN'));
                  language = 'zh_CN';
                  saveLanguageSetting(language);
                } else if (value == "English") {
                  S.load(const Locale('en', 'US'));
                  language = 'en_US';
                  saveLanguageSetting(language);
                }

                // else if (value == "袪褍褋褋泻懈泄") {
                //   S.load(const Locale('ru', 'RU'));
                //   saveLanguageSetting('ru_RU');
                // } else if (value == "鏃ユ湰瑾?) {
                //   S.load(const Locale('ja', 'JP'));
                //   saveLanguageSetting('ja_JP');
                // } else if (value == "Italiano") {
                //   S.load(const Locale('it', 'IT'));
                //   saveLanguageSetting('it_IT');
                // } else if (value == "Portugu锚s") {
                //   S.load(const Locale('pt', 'PT'));
                //   saveLanguageSetting('pt_PT');
                // } else if (value == "Fran莽ais") {
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
      //   if (value == "涓枃") {
      //     S.load(const Locale('zh', 'CN'));
      //     saveLanguageSetting('zh_CN');
      //   } else if (value == "English") {
      //     S.load(const Locale('en', 'US'));
      //     saveLanguageSetting('en_US');
      //   } else if (value == "袪褍褋褋泻懈泄") {
      //     S.load(const Locale('ru', 'RU'));
      //     saveLanguageSetting('ru_RU');
      //   } else if (value == "鏃ユ湰瑾?) {
      //     S.load(const Locale('ja', 'JP'));
      //     saveLanguageSetting('ja_JP');
      //   } else if (value == "Italiano") {
      //     S.load(const Locale('it', 'IT'));
      //     saveLanguageSetting('it_IT');
      //   } else if (value == "Portugu锚s") {
      //     S.load(const Locale('pt', 'PT'));
      //     saveLanguageSetting('pt_PT');
      //   } else if (value == "Fran莽ais") {
      //     S.load(const Locale('fr', 'FR'));
      //     saveLanguageSetting('fr_FR');
      //   }
      // });
    }
  }
}


