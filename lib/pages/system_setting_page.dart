import 'package:flutter/material.dart';
import '../data/company_info.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';
import '../dialog/get_build_info_dialog.dart';
import '../dialog/language_setting.dart';
import '../eventbus/eventbus.dart';
import '../widget/custom_circle_icon.dart';
import '../dialog/license_info.dart';
import '../widget/home_page_widget.dart';
import '../widget/page_head.dart';

class SystemSettingPage extends StatefulWidget {
  const SystemSettingPage({super.key});

  @override
  State<SystemSettingPage> createState() => _SystemSettingPageState();
}

class _SystemSettingPageState extends State<SystemSettingPage> {
  List<String> items = [];
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  late ScrollController _pageScrollerController;

  String groupValue = 'zh';
  bool isCardHovered = false;
  bool isCardClicked = false;

  dynamic eventBus1;

  // 初始文字颜色
  @override
  void initState() {
    super.initState();
    _pageScrollerController = ScrollController();
    cntScaleTimerMgr.stopCntScaleTimer();
    eventBus1 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        // setState(() {
        //   myFactoryInfoFromScale = event.obj;
        //   if (myFactoryInfoFromScale.modelName != '') {
        //     myComScaleInfo.isOnline = true;
        //   } else {
        //     myComScaleInfo.isOnline = false;
        //   }
        // });
      }
    });
  }

  @override
  void dispose() {
    _pageScrollerController.dispose();
    eventBus1.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: pageHeadDefScale(
          context,
          myAppName.appName!,
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceBright,
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
                  color: Theme.of(context).colorScheme.surfaceTint,
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    firstCard(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget functionTitle(String titleName, IconData iconName) {
    return Row(
      children: [
        CustomCircleIcon(
          outerColor: Theme.of(context).colorScheme.primary,
          innerColor: Theme.of(context).colorScheme.onPrimary,
          icon: iconName,
          size: 30.0,
        ),
        Text(titleName),
      ],
    );
  }

  Widget settingCard(String titleName, IconData iconInfo) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Theme.of(context).colorScheme.surfaceTint,
        child: SizedBox(
            height: 80,
            child: Row(
              children: [
                Container(
                  width: 3.0,
                  height: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  width: 25,
                ),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return lineGradient(context).createShader(bounds);
                  },
                  child: Icon(
                    size: 30,
                    iconInfo,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: Text(
                    titleName,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            )));
  }

  Widget firstCard() {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        margin: const EdgeInsets.only(right: 20), // 根据实际需要设置容器间距
        child: ListView(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            children: [
              functionTitle(localizedStrings.gSystemSetting, Icons.settings),
              const SizedBox(
                height: 10,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click, // 设置光标为手的形状
                child: GestureDetector(
                  onTap: () {
                    setLanguageDialog(context);
                  },
                  child: settingCard(
                      localizedStrings.gTitleSetLanguage, Icons.language),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click, // 设置光标为手的形状
                child: GestureDetector(
                  onTap: () {
                    showLicenseDialog(context);
                  },
                  child: settingCard(
                    localizedStrings.gTitleLicenseInfo,
                    Icons.key,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click, // 设置光标为手的形状
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showBuildInfo();
                    });
                  },
                  child: settingCard(
                    localizedStrings.gTitleGetBuildInfo,
                    Icons.key,
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  void showBuildInfo() {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const GetBuildInfoPage();
      },
    ).then((value) => setState(() {}));
  }

  void showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const LicenseInfoDialog();
      },
    ).then((value) => setState(() {}));
  }

  void setLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const LanguageSettingPage();
      },
    ).then((value) => setState(() {}));
  }
}
