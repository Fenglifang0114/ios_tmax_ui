import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/main.dart';
import 'package:t_max/pages/dialog/showComPort_dialog.dart';
import 'package:t_max/pages/widget/TimerWidget.dart';
import 'widget/version.dart';
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
    // final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: AppBar(
            title: version(),
            leading: const Text(''),
            actions: [
              Row(
                children: [
                  SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        SizedBox(
                          child: TimerWidget(),
                        ),
                        const SizedBox(width: 30),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  // PopupMenuButton(
                  //   offset: const Offset(0, 40),
                  //   onSelected: (value) {
                  //     _changed(value);
                  //   },
                  //   itemBuilder: (BuildContext context) => [
                  //     PopupMenuItem(
                  //         value: "zh",
                  //         child: Text(
                  //           "简体中文",
                  //           style: Theme.of(context).textTheme.bodyMedium,
                  //         )),
                  //     PopupMenuItem(
                  //         value: "en",
                  //         child: Text(
                  //           "English",
                  //           style: Theme.of(context).textTheme.bodyMedium,
                  //         )),
                  //   ],
                  // ),
                ],
              )
            ],
          )),
      //左侧边栏
      // drawer: leftSidebar(context),

      body: ListView(
        // 水平拉伸
        scrollDirection: Axis.horizontal,
        children: [
          Container(
            width: 20,
            color: Colors.blue.shade900,
          ),
          Row(
            children: [
              //左侧添加设备
              // Container(
              //   width: 200,
              //   decoration: const BoxDecoration(
              //       border: Border(
              //           right: BorderSide(width: 0.5, color: Colors.black))),
              //   child: Column(
              //     children: <Widget>[
              //       // Row(
              //       //   children: [
              //       //     const Icon(Icons.device_hub),
              //       //     Text(S.of(context).operation_tips),
              //       //   ],
              //       // ),
              //       const SizedBox(height: 10),
              //       Expanded(child: Row()),
              //       Container(
              //         height: 20,
              //         color: Colors.blue.shade900,
              //       ),
              //     ],
              //   ),
              // ),
              // const Flexible(flex: 1, child: GridPage())
              //右侧重量显示
              SizedBox(
                  width: _width - 200,
                  child: Column(
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          const SizedBox(height: 100),
                          const Text("T-Max management system",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 50)),
                          const SizedBox(height: 100),
                          ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)))),
                              // const BorderRadius.all(Radius.circular(8)),
                              onPressed: () {
                                // getPortList();
                                getScaleList();
                                // getProductList();
                                getUIConf();
                                // getUserList();
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const ScaleHomePage(); //AddDevicePage();
                                }));
                              },
                              child: const Text("Click to start",
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.normal))),
                        ],
                      )),
                      Container(
                          height: 20,
                          color: Colors.blue.shade900,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text("Contact us: Email:sales@taiwanscale.com",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                            ],
                          )),
                    ],
                  ))
            ],
          )
        ],
      ),
    );
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





