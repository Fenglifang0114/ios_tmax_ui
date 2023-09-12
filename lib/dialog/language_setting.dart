import 'package:flutter/material.dart';
import 'package:t_max/pages/home_page.dart';
import '../../generated/l10n.dart';

class LanguageSettingPage extends StatefulWidget {
  const LanguageSettingPage({super.key});

  @override
  _LanguageSettingPageState createState() => _LanguageSettingPageState();
}

class _LanguageSettingPageState extends State<LanguageSettingPage> {
  List<String> languageList = ['中文', 'English'];
  dynamic localizedStrings;
  String language = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
    if (localizedStrings.zh_cn == 'Chinese') {
      language = 'English';
    } else {
      language = '中文';
    }
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
          color: Colors.blue.shade900,
          child: Row(
            children: [
              const Icon(Icons.usb, color: Colors.white),
              Text(localizedStrings.language_setting_title,
                  style: const TextStyle(color: Colors.white))
            ],
          )),
      content: Container(
        height: 356,
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 233, 232, 232)),
        child: Column(
          children: [
            const SizedBox(height: 2),
            Container(
              decoration: const BoxDecoration(color: Colors.white),
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
            OutlinedButton(
                child: Text(localizedStrings.button_ok),
                onPressed: () {
                  setState(() {});
                  // Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }),
            const SizedBox(width: 20),
            OutlinedButton(
                child: Text(localizedStrings.button_cancel),
                onPressed: () {
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
        if (value == "中文") S.load(const Locale('zh', 'CN'));
        if (value == "English") S.load(const Locale('en', 'US'));
      });
    }
  }
}
