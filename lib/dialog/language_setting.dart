import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n.dart';
import '../widget/custom_button.dart';

class LanguageSettingPage extends StatefulWidget {
  const LanguageSettingPage({super.key});

  @override
  LanguageSettingPageState createState() => LanguageSettingPageState();
}

class LanguageSettingPageState extends State<LanguageSettingPage> {
  List<String> languageList = [
    '中文',
    'English',
    'Русский',
    'Português',
    'Italiano',
    'Français',
    'Deutsch',
    '日本語',
    '한국어'
  ];
  dynamic localizedStrings;
  String language = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
    if (localizedStrings.current_language == 'Chinese') {
      language = 'English';
    } else if ((localizedStrings.current_language == 'Русский')) {
      language = 'Русский';
    } else if (localizedStrings.current_language == '中文') {
      language = '中文';
    } else {
      language = 'English';
    }
  }

  void saveLanguageSetting(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: getDialogTitle(context, localizedStrings.language_setting_title,
          Icons.language, 400),
      content: Container(
        height: 356,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
        child: Column(
          children: [
            const SizedBox(height: 2),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceTint),
              child: Column(
                children: [
                  // const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 360,
                            height: 100,
                            child: DropdownButtonFormField(
                                value: language,
                                items: languageList
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem(
                                      value: value, child: Text(value));
                                }).toList(),
                                onChanged: _changed),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 20),
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.exit_to_app,
              text: localizedStrings.button_exit,
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }

  void _changed(value) {
    if (value != null) {
      // SpUtil.putString(SpConstant.LANGUAGE, value);
      setState(() {
        if (value == "中文") {
          S.load(const Locale('zh', 'CN'));
          saveLanguageSetting('zh_CN');
        } else if (value == "English") {
          S.load(const Locale('en', 'US'));
          saveLanguageSetting('en_US');
        } else if (value == "Русский") {
          S.load(const Locale('ru', 'RU'));
          saveLanguageSetting('ru_RU');
        }
      });
    }
  }
}
