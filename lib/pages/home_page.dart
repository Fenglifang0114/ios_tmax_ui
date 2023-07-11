import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/main.dart';
import 'package:t_max/pages/labeldesign_page.dart';
import 'package:t_max/pages/wifisetting_page.dart';
import 'dialog/modifyBluetooth_dialog.dart';
import 'widget/bluetoothsetting.dart';
import 'widget/boxGradient.dart';
import 'widget/customcard.dart';
import 'scalehome_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

// late int connectionType;

class _HomePageState extends State<HomePage> {
  List<String> items = [];
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  List<DataRow> dataRows = [];

  late ScrollController _pageScrollerController;
  dynamic _eventbus1;
  dynamic _eventbus2;
  String groupValue = 'zh';
  DateTime now = DateTime.now();

  List<Color> cardColors = List.generate(6, (index) => Colors.white);
  List<Color> textColors = List.generate(6, (index) => Colors.blue.shade900);
  List<Widget> targetPages = [
    const ScaleHomePage(), // 第一个Card对应的目标界面
    const LabelDesignPage(), // 第二个Card对应的目标界面
    const WifiSettingPage(), // 第三个Card对应的目标界面
    const LabelDesignPage(), // 第一个Card对应的目标界面
    const LabelDesignPage(), // 第二个Card对应的目标界面
    const LabelDesignPage(), // 第三个Card对应的目标界面
    // ...
  ];

  List<String> imagePaths = [
    'images/11.png',
    'images/12.png',
    'images/13.png',
    'images/14.png',
    'images/15.png',
    'images/16.png',
  ];

  List<String> titleNames = [
    'Scale Data',
    'Label Design',
    'Wifi Setting',
    'Bluetooth Setting',
    'title5',
    'title6',
  ];
  // 初始文字颜色

  @override
  void initState() {
    super.initState();
    _pageScrollerController = ScrollController();
    _eventbus1 = eventBus.on<EventDialogData>().listen((event) {
      if (mounted) {
        setState(() {
          myDialogData = event.obj;
        });
      }
    });
    setState(() {
      now = DateTime.now();
    });
    _eventbus2 = eventBus.on<EventScaleList>().listen((event) {
      if (mounted) {
        setState(() {
          // myScaleList = event.obj;
          // print(myScaleList.msgBody![0].scaleModel.toString());
        });
      }
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _pageScrollerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    // final _height = MediaQuery.of(context).size.height;
    return Scaffold(
        // appBar: PreferredSize(
        //     preferredSize: const Size.fromHeight(30),
        //     child: AppBar(
        //       title: version(),
        //       leading: const Text(''),
        //       actions: [
        //         Row(
        //           children: [
        //             SizedBox(
        //               height: 20,
        //               child: Row(
        //                 children: [
        //                   SizedBox(
        //                     child: TimerWidget(),
        //                   ),
        //                   const SizedBox(width: 30),
        //                 ],
        //               ),
        //             ),
        //             const SizedBox(width: 30),
        //             // PopupMenuButton(
        //             //   offset: const Offset(0, 40),
        //             //   onSelected: (value) {
        //             //     _changed(value);
        //             //   },
        //             //   itemBuilder: (BuildContext context) => [
        //             //     PopupMenuItem(
        //             //         value: "zh",
        //             //         child: Text(
        //             //           "简体中文",
        //             //           style: Theme.of(context).textTheme.bodyMedium,
        //             //         )),
        //             //     PopupMenuItem(
        //             //         value: "en",
        //             //         child: Text(
        //             //           "English",
        //             //           style: Theme.of(context).textTheme.bodyMedium,
        //             //         )),
        //             //   ],
        //             // ),
        //           ],
        //         )
        //       ],
        //     )),
        //左侧边栏
        // drawer: leftSidebar(context),

        body: Container(
      height: _height,
      width: _width,
      decoration: BoxDecoration(gradient: boxGradient()),
      child: ListView(
        // 水平拉伸
        scrollDirection: Axis.horizontal,
        children: [
          Container(
            height: _height,
            width: _width,
            decoration: BoxDecoration(gradient: boxGradient()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  children: [
                    const SizedBox(height: 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomCard(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => targetPages[0]),
                              );
                            });
                          },
                          title: titleNames[0],
                          cardColor: cardColors[0],
                          textColor: textColors[0],
                          image: imagePaths[0],
                        ),
                        CustomCard(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => targetPages[1]),
                              );
                            });
                          },
                          title: titleNames[1],
                          cardColor: cardColors[1],
                          textColor: textColors[1],
                          image: imagePaths[1],
                        ),
                        CustomCard(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => targetPages[2]),
                              );
                            });
                          },
                          title: titleNames[2],
                          cardColor: cardColors[2],
                          textColor: textColors[2],
                          image: imagePaths[2],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomCard(
                          onTap: () {
                            setState(() {
                              setBlueToothDialog(context).then((onValue) {});
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => targetPages[3]),
                              // );
                            });
                          },
                          title: titleNames[3],
                          cardColor: cardColors[3],
                          textColor: textColors[3],
                          image: imagePaths[3],
                        ),
                        CustomCard(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => targetPages[4]),
                              );
                            });
                          },
                          title: titleNames[4],
                          cardColor: cardColors[4],
                          textColor: textColors[4],
                          image: imagePaths[4],
                        ),
                        CustomCard(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => targetPages[5]),
                              );
                            });
                          },
                          title: titleNames[5],
                          cardColor: cardColors[5],
                          textColor: textColors[5],
                          image: imagePaths[5],
                        ),
                      ],
                    ),
                  ],
                )),
                Container(
                    height: 20,
                    color: Colors.blue.shade900,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Contact us: Email:sales@taiwanscale.com",
                            style:
                                TextStyle(color: Colors.white, fontSize: 15)),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  void getScaleList() {
    myScaleCmd.cmdMode = "get_scale_list";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  void getProductList() {
    myScaleCmd.cmdMode = "get_product_list";
    myScaleCmd.cmdData = "";
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
  }

  // void _changed(value) {
  //   if (value != null) {
  //     //SpUtil.putString(SpConstant.LANGUAGE, value);
  //     setState(() {
  //       groupValue = value;
  //       if (value == "zh") S.load(const Locale('zh', 'CN'));
  //       if (value == "en") S.load(const Locale('en', 'US'));
  //     });
  //   }
  // }
}








/*//////导航栏模式
///
///
/// final List<Widget> _mainContents = [
    // Content for Home tab
    Container(
      // width: _width - 200,
      child: const AddDevicePage(),
      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) {
      //   return const AddDevicePage();
      // }));
    ),
    // Content for Feed tab
    Container(
      color: Colors.purple.shade100,
      alignment: Alignment.center,
      child: const Text(
        'Feed',
        style: TextStyle(fontSize: 40),
      ),
    ),
    // Content for Favorites tab
    Container(
      color: Colors.red.shade100,
      alignment: Alignment.center,
      child: const Text(
        'Favorites',
        style: TextStyle(fontSize: 40),
      ),
    ),
    // Content for Settings tab
    Container(
      color: Colors.pink.shade300,
      alignment: Alignment.center,
      child: const Text(
        'Settings',
        style: TextStyle(fontSize: 40),
      ),
    )
  ];

  // The index of the selected tab
  // In the beginning, the Home tab is selected
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(30),
            child: AppBar(
              title: version(),
            )),
        // appBar: AppBar(
        //   title: const Text('大前端之旅'),
        // ),
        body: ListView(
            // 水平拉伸
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                  child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  NavigationRail(
                    backgroundColor: const Color.fromARGB(235, 235, 235, 235),
                    minWidth: 44.0,
                    selectedIndex: _selectedIndex,
                    // Called when one tab is selected
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    labelType: NavigationRailLabelType.all,
                    selectedLabelTextStyle: const TextStyle(
                      color: Color.fromARGB(255, 13, 71, 161),
                    ),
                    leading: Column(
                      children: const [
                        SizedBox(
                          height: 8,
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Color.fromARGB(255, 13, 71, 161),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    unselectedLabelTextStyle:
                        const TextStyle(color: Color.fromARGB(255, 86, 86, 86)),
                    // navigation rail items
                    destinations: const [
                      NavigationRailDestination(
                          icon: Icon(Icons.home), label: Text('Home')),
                      NavigationRailDestination(
                          icon: Icon(Icons.design_services),
                          label: Text('Design')),
                      NavigationRailDestination(
                          icon: Icon(Icons.receipt_rounded),
                          label: Text('Report')),
                      NavigationRailDestination(
                          icon: Icon(Icons.settings), label: Text('Setting')),
                    ],
                  ),

                  // Main content
                  // This part is always shown
                  // You will see it on both small and wide screen
                  SizedBox(
                      width: _width,
                      child: Column(
                        children: [
                          Expanded(
                            child: _mainContents[_selectedIndex],
                          ),
                          Container(
                              height: 20,
                              color: Colors.blue.shade900,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("联系我们：http://www.xxxxxxxxxxx",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15)),
                                ],
                              )),
                        ],
                      ))
                ],
              )),
            ]));
  }
}


*/////





