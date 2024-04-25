import 'package:flutter/material.dart';
import '../data/scale_info_from_scale.dart';
import '../data/screen_mgr.dart';
import '../data/setting_version_info.dart';
import '../data/timer_manager.dart';
import '../dialog/language_setting.dart';
import '../eventbus/eventbus.dart';
import '../generated/l10n.dart';
import '../widget/custom_circle_icon.dart';
import '../dialog/license_info.dart';
import '../widget/page_head.dart';

class SystemSettingPage extends StatefulWidget {
  const SystemSettingPage({Key? key}) : super(key: key);

  @override
  State<SystemSettingPage> createState() => _SystemSettingPageState();
}

class _SystemSettingPageState extends State<SystemSettingPage> {
  List<String> items = [];
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  late ScrollController _pageScrollerController;

  String groupValue = 'zh';

  List<Color> cardColors = List.generate(9, (index) => Colors.white);
  List<Color> textColors = List.generate(9, (index) => Colors.blue.shade900);

  List<String> imagePaths = [
    'assets/images/11.png',
    'assets/images/12.png',
    'assets/images/13.png',
    'assets/images/14.png',
    'assets/images/15.png',
    'assets/images/16.png',
  ];
  bool isCardHovered = false;
  bool isCardClicked = false;

  dynamic eventBus1;

  // 初始文字颜色
  @override
  void initState() {
    super.initState();
    _pageScrollerController = ScrollController();
    cntScaleTimerMgr.stopCntScaleTimer();
    eventBus1 = eventBus.on<EventRespCheckSerialPort>().listen((event) {
      if (mounted) {
        setState(() {
          myFactoryInfoFromScale = event.obj;
          if (myFactoryInfoFromScale.modelName != '') {
            myScreenMgr.serialPortST = true;
          } else {
            myScreenMgr.serialPortST = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageScrollerController.dispose();
    eventBus1.cancel();
    super.dispose();
  }

  dynamic localizedStrings;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  Widget build(BuildContext context) {
    // final _width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;
    // final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: pageHead(context, mySystemVersionInfo.getTitle(mySystemVersion),
            localizedStrings.serial_port_status),
      ),

      // Container(
      //   color: Theme.of(context).colorScheme.onPrimary,
      //   // foregroundColor: Theme.of(context).colorScheme.primary,
      //   child: Container(
      //     decoration: BoxDecoration(gradient: boxGradient()),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Center(
      //           child: SizedBox(
      //             width: 300,
      //             child: Text(
      //               mySystemVersionInfo.getTitle(mySystemVersion),
      //               style: TextStyle(
      //                   fontSize: 20,
      //                   color: Theme.of(context).colorScheme.onPrimary),
      //               textAlign: TextAlign.center,
      //             ),
      //           ),
      //         ),
      //         // SizedBox(
      //         //     width: 240,
      //         //     height: 50,
      //         //     child: IconButton(
      //         //         onPressed: () {
      //         //           myScreenMgr.isMainScreen = true;
      //         //           Navigator.of(context).pop();
      //         //         },
      //         //         icon: CustomCircleIcon(
      //         //           outerColor: Theme.of(context).colorScheme.onPrimary,
      //         //           innerColor: Theme.of(context).colorScheme.primary,
      //         //           icon: Icons.home,
      //         //           size: 30.0,
      //         //         ))),
      //       ],
      //     ),
      //   ),
      //   //设置状态栏颜色渐变
      //   // flexibleSpace:
      //   //     Container(decoration: BoxDecoration(gradient: boxGradient())),
      // )),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // 根据实际需要设置圆角半径
                  color: Theme.of(context).colorScheme.onPrimary,
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

  LinearGradient lineGradient() {
    return const LinearGradient(
      colors: [
        Color.fromARGB(255, 21, 129, 238),
        Color.fromARGB(255, 115, 238, 207),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget customFunctionCard(
      String titleName, String iconImage, IconData iconInfo) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Theme.of(context).colorScheme.onPrimary,
        child: SizedBox(
            height: 80,
            child: Row(
              children: [
                Image.asset(
                  iconImage,
                  width: 30,
                  height: 30,
                ),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return lineGradient().createShader(bounds);
                  },
                  child: Icon(
                    size: 30,
                    iconInfo,
                    color: Colors.white,
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
          color: Theme.of(context).colorScheme.tertiary,
        ),
        margin: const EdgeInsets.only(right: 20), // 根据实际需要设置容器间距
        child: ListView(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            children: [
              functionTitle(
                  localizedStrings.system_setting_title, Icons.settings),
              const SizedBox(
                height: 10,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click, // 设置光标为手的形状
                child: GestureDetector(
                  onTap: () {
                    setLanguageDialog(context);
                  },
                  child: customFunctionCard(localizedStrings.set_language_title,
                      "assets/images/line.png", Icons.language),
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
                  child: customFunctionCard(localizedStrings.license_info_title,
                      "assets/images/line.png", Icons.info),
                ),
              ),
            ]),
      ),
    );
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
