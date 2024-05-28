import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n.dart';

class LanguageSettingPage extends StatefulWidget {
  const LanguageSettingPage({super.key});

  @override
  _LanguageSettingPageState createState() => _LanguageSettingPageState();
}

class _LanguageSettingPageState extends State<LanguageSettingPage> {
  List<String> languageList = ['中文', 'English', 'Русский'];
  dynamic localizedStrings;
  String language = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
    if (localizedStrings.zh_cn == 'Chinese') {
      language = 'English';
    } else if ((localizedStrings.zh_cn == 'Китайский')) {
      language = 'Русский';
    } else {
      language = '中文';
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
      title: Container(
          width: 400,
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            children: [
              Icon(Icons.language,
                  color: Theme.of(context).colorScheme.onPrimary),
              Text(localizedStrings.language_setting_title,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary))
            ],
          )),
      content: Container(
        height: 356,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
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
            // OutlinedButton(
            //     child: Text(localizedStrings.button_ok),
            //     onPressed: () {
            //       setState(() {});
            //       // myScreenMgr.isMainScreen = true;
            // Navigator.of(context).pop();
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => const HomePage()),
            //       );
            //     }),
            const SizedBox(width: 20),
            OutlinedButton(
                child: Text(localizedStrings.button_exit),
                onPressed: () {
                  setState(() {});
                  Navigator.of(context)
                      .pop(); // to go back to screen after submitting
                })
          ],
        )
      ],
    );
  }

  void _changed(value) {
    if (value != null) {
      //SpUtil.putString(SpConstant.LANGUAGE, value);
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
