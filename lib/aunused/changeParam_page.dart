import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/weightparam_data.dart';
import '../data/date_data.dart';
import '../data/device_data.dart';
import '../data/time_data.dart';
import '../eventbus/eventbus.dart';
import '../widget/appbar_msg.dart';
import '../widget/dropdown.dart';
import '../widget/theme_color.dart';
import '../widget/version.dart';
import 'left_side_bar.dart';

class ChangeParamPage extends StatefulWidget {
  const ChangeParamPage({Key? key}) : super(key: key);

  @override
  State<ChangeParamPage> createState() => _ChangeParamPageState();
}

class _ChangeParamPageState extends State<ChangeParamPage> {
  List<String> items = [];
  List<DataRow> dataRows = [];
  final TextEditingController _gravitycontroller =
      TextEditingController(text: "9.79640");

  late ScrollController _pageScrollerController;

  bool isRangeChecked = true;
  bool isPrecisionChecked = true;
  bool isGraduationChecked = true;
  bool isWeightDecimalChecked = true;
  bool isAccumulateChecked = true;
  bool isSerialPortChecked = true;
  bool isPrinterChecked = true;
  bool isAutoShutdownChecked = true;
  bool isBillChecked = true;
  bool isTaxChecked = true;
  bool isZeroTrackChecked = true;
  bool isBacklightChecked = true;
  bool isbaudChecked = true;
  bool isGravityChecked = true;
  bool isLanguageChecked = true;
  bool iscurrencyChecked = true;
  bool istimeChecked = true;
  bool accumulate = true;
  bool bill = true;
  List<String> unitList = ['g', 'kg', 'lb'];
  List<String> max1List = ['6', '15', '30'];
  List<String> max2List = ['3', '6', '15'];
  List<String> graduation1List = ['1', '2', '5'];
  List<String> graduation2List = ['2', '5', '10'];
  List<String> weightDecimalList = ['0', '1', '2', '3', '4', '5'];
  List<String> serialPortList = ['rs232', 'LP50'];
  List<String> printerList = ['LP50', 'PRT', 'RP58E'];
  List<String> autoShutdownList = ['关闭', '3分钟', '5分钟', '10分钟', '30分钟', '1小时'];
  List<String> taxList = ['外加税', '内置税', '关闭'];
  List<String> zeroTrackList = ['0d', '0.5d', '1d', '2d'];
  List<String> backlightList = ['自动', '关闭', '打开'];
  List<String> baudList = ['9600', '115200', '4800'];
  List<String> languageList = ['中文', '英文', '俄语'];
  List<String> currencyList = ['元', '美元', '卢布'];

  int _part = 1;

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;

  @override
  void initState() {
    super.initState();
    _pageScrollerController = ScrollController();
    _eventbus1 = eventBus.on<EventDeviceName>().listen((event) {
      if (mounted) {
        setState(() {
          myDevicedata = event.obj;
        });
      }
    });
    _eventbus2 = eventBus.on<EventDate>().listen((event) {
      if (mounted) {
        setState(() {
          myDate.date = event.obj;
        });
      }
    });
    _eventbus3 = eventBus.on<EventTime>().listen((event) {
      if (mounted) {
        setState(() {
          myTime.time = event.obj;
        });
      }
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _pageScrollerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width - 20;
    final _height = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeColor(),
      home: Scaffold(
        drawer: leftSidebar(context),
        // AppBar：相当于iOS 的导航栏
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: AppBar(
              title: version(),
              actions: [appbarMsg(context)],
            )),
        body: ListView(
          // 水平拉伸
          scrollDirection: Axis.horizontal,
          children: [
            Container(
              width: 20,
              color: Colors.blue.shade900,
            ),
            Container(
                width: _width,
                height: _height,
                decoration: const BoxDecoration(color: Colors.white),
                child: ListView(
                  controller: _pageScrollerController,
                  children: [
                    const SizedBox(height: 20),
                    //恢复默认设置
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                            onPressed: () {},
                            child: const Text(
                              "恢复默认设置",
                              style: TextStyle(fontSize: 30),
                            )),
                        const SizedBox(width: 50),
                      ],
                    ),
                    const SizedBox(height: 10),
                    //精度模式
                    Row(
                      children: [
                        const SizedBox(width: 50),
                        Checkbox(
                            // activeColor: Colors.black,
                            value: isPrecisionChecked,
                            onChanged: (value) {
                              setState(() {
                                isPrecisionChecked = value!;
                              });
                            }),
                        const Text("精度模式"),
                        const SizedBox(width: 50),
                        Radio(
                            value: 1,
                            groupValue: _part,
                            onChanged: (value) {
                              debugPrint(value.toString());
                              setState(() {
                                _part = 1;
                              });
                            }),
                        const Text("单精度"),
                        const SizedBox(width: 50),
                        Radio(
                            value: 2,
                            groupValue: _part,
                            onChanged: (value) {
                              debugPrint(value.toString());
                              setState(() {
                                _part = 2;
                              });
                            }),
                        const Text("双分度值"),
                        const SizedBox(width: 50),
                        Radio(
                            value: 3,
                            groupValue: _part,
                            onChanged: (value) {
                              debugPrint(value.toString());
                              setState(() {
                                _part = 3;
                                eventBus.fire(EventWeightParamData(
                                    myWeightParamData)); //FLF
                              });
                            }),
                        const Text("双量程"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    //量程
                    Row(
                      children: [
                        const SizedBox(width: 50),
                        Checkbox(
                            value: isRangeChecked,
                            onChanged: (value) {
                              setState(() {
                                isRangeChecked = value!;
                                if (kDebugMode) {
                                  print(isRangeChecked);
                                }
                              });
                            }),
                        const Text("量程"),
                        const SizedBox(width: 80),
                        const Text("单位"),
                        const SizedBox(width: 35),
                        // _unit(),
                        Dropdown(unitList),
                        const SizedBox(width: 40),
                        const Text("Max1"),
                        const SizedBox(width: 31),
                        // _max1(),
                        Dropdown(max1List),
                        const SizedBox(width: 40),
                        const Text("Max2"),
                        const SizedBox(width: 31),
                        Dropdown(max2List),
                      ],
                    ),
                    const SizedBox(height: 10),
                    //分度值
                    Row(
                      children: [
                        const SizedBox(width: 50),
                        Checkbox(
                            value: isGraduationChecked,
                            onChanged: (value) {
                              setState(() {
                                isGraduationChecked = value!;
                              });
                            }),
                        const Text("分度值"),
                        const SizedBox(width: 65),
                        const Text("分度值1"),
                        const SizedBox(width: 15),
                        Dropdown(graduation1List),
                        const SizedBox(width: 40),
                        const Text("分度值2"),
                        const SizedBox(width: 15),
                        Dropdown(graduation2List),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 50),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                    value: isWeightDecimalChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isWeightDecimalChecked = value!;
                                      });
                                    }),
                                const Text("重量小数点")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: isAccumulateChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isAccumulateChecked = value!;
                                      });
                                    }),
                                const Text("累加")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: isSerialPortChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isSerialPortChecked = value!;
                                      });
                                    }),
                                const Text("串口")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: isPrinterChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isPrinterChecked = value!;
                                      });
                                    }),
                                const Text("打印机")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: isAutoShutdownChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isAutoShutdownChecked = value!;
                                      });
                                    }),
                                const Text("自动关机")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: isBillChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isBillChecked = value!;
                                      });
                                    }),
                                const Text("结账")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: isBillChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isBillChecked = value!;
                                      });
                                    }),
                                const Text("税率")
                              ],
                            )
                          ],
                        ),
                        const SizedBox(width: 50),
                        Column(
                          children: [
                            //重量小数点
                            Dropdown(weightDecimalList),
                            const SizedBox(height: 8),
                            //累加
                            Switch(
                              value: accumulate, //当前状态
                              onChanged: (value) {
                                //重新构建页面
                                setState(() {
                                  accumulate = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            //串口
                            Dropdown(serialPortList),
                            const SizedBox(height: 10),
                            //打印机
                            Dropdown(printerList),
                            const SizedBox(height: 10),
                            //自动关机
                            Dropdown(autoShutdownList),
                            const SizedBox(height: 6),
                            //结账
                            Switch(
                              value: bill, //当前状态
                              onChanged: (value) {
                                //重新构建页面
                                setState(() {
                                  bill = value;
                                });
                              },
                            ),
                            const SizedBox(height: 6),
                            //税率
                            Dropdown(taxList),
                          ],
                        ),
                        const SizedBox(width: 100),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                    value: isZeroTrackChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isZeroTrackChecked = value!;
                                      });
                                    }),
                                const Text("零点追踪")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: isBacklightChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isBacklightChecked = value!;
                                      });
                                    }),
                                const Text("背光")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: isbaudChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isbaudChecked = value!;
                                      });
                                    }),
                                const Text("波特率")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: isGravityChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isGravityChecked = value!;
                                      });
                                    }),
                                const Text("重力加速度")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: isLanguageChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isLanguageChecked = value!;
                                      });
                                    }),
                                const Text("语言")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: iscurrencyChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        iscurrencyChecked = value!;
                                      });
                                    }),
                                const Text("货币")
                              ],
                            ),
                            const SizedBox(height: 26),
                            Row(
                              children: [
                                Checkbox(
                                    value: istimeChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        istimeChecked = value!;
                                      });
                                    }),
                                const Text("时间")
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 50),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //零点追踪
                            Dropdown(zeroTrackList),
                            const SizedBox(height: 8),
                            //背光
                            Dropdown(backlightList),
                            const SizedBox(height: 8),
                            //波特率
                            Dropdown(baudList),
                            const SizedBox(height: 15),
                            //重力加速度
                            Container(
                              width: 200,
                              height: 32,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)),
                              child: TextField(
                                controller: _gravitycontroller,
                                textAlignVertical: TextAlignVertical.center,
                                textAlign: TextAlign.start,
                              ),
                              // gravity
                            ),
                            const SizedBox(height: 12),
                            //语言
                            Dropdown(languageList),
                            const SizedBox(height: 10),
                            //货币
                            Dropdown(currencyList),
                            const SizedBox(height: 10),
                            //时间
                            Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 32,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey)),
                                  child: TextField(
                                    // controller: _gravitycontroller,
                                    // enabled: false,
                                    showCursor: false,
                                    textAlignVertical: TextAlignVertical.center,
                                    textAlign: TextAlign.end,
                                    decoration: InputDecoration(
                                        hintText: myDate.date + "⋁"),
                                    onTap: () {
                                      setState(() {
                                        showDatePicker(
                                          context: context,
                                          initialDate:
                                              DateTime.now(), // 初始化选中日期
                                          firstDate: DateTime(2000, 1), // 开始日期
                                          lastDate: DateTime(2050, 12), // 结束日期
                                          textDirection:
                                              TextDirection.ltr, // 文字方向
                                          cancelText: "Cancel", // 取消按钮文案
                                          confirmText: "Ok", // 确认按钮文案
                                        ).then((value) {
                                          _date(value);
                                        });
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  width: 80,
                                  height: 32,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey)),
                                  child: TextField(
                                    // controller: _gravitycontroller,
                                    // enabled: false,
                                    showCursor: false,
                                    textAlignVertical: TextAlignVertical.center,
                                    textAlign: TextAlign.end,
                                    decoration: InputDecoration(
                                        hintText: myTime.time + "⋁"),
                                    onTap: () {
                                      setState(() {
                                        showTimePicker(
                                                context: context,
                                                builder: (context, child) {
                                                  return Theme(
                                                      data: ThemeData(
                                                          cardColor:
                                                              Colors.white,
                                                          brightness:
                                                              Brightness.light),
                                                      child: child!);
                                                },
                                                initialTime: const TimeOfDay(
                                                    hour: 11, minute: 11),
                                                cancelText: "取消",
                                                confirmText: "确定")
                                            .then((value) {
                                          _time(value);
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            onPressed: () {}, child: const Text("确定")),
                        const SizedBox(width: 100)
                      ],
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  void _date(value) {
    if (value != null) {
      myDate.date = value.toString().split(" ")[0];
      return eventBus.fire(EventDate(myDate.date));
    } else {
      myDate.date;
    }
  }

  void _time(value) {
    if (value != null) {
      //字符串截取
      myTime.time = value.toString().substring(10, 15);
      return eventBus.fire(EventTime(myTime.time));
    } else {
      myTime.time;
    }
  }

  // _unit() {
  //   if (isRangeChecked == true) {
  //     eventBus.fire(EventDialogData(myDialogData));
  //     return Dropdown(unitList);
  //   }
  //   return Dropdown(unitList);
  // }

  // _max1() {
  //   if (isPrecisionChecked == true) {
  //     eventBus.fire(EventDialogData(myDialogData));
  //     return Dropdown(max1List);
  //   }
  //   return Dropdown(max1List);
  // }
}
