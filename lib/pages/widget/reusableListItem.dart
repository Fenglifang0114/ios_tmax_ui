import 'package:flutter/material.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/currentport_data.dart';

import '../../data/device_data.dart';
import '../../eventbus/eventbus.dart';

// ignore: must_be_immutable
class ReusableListItem extends StatefulWidget {
  ReusableListItem(this.pill, {Key? key}) : super(key: key);
  late String pill;
  @override
  State<ReusableListItem> createState() => _ReusableListItemState();
}

// late int connectionType;
class _ReusableListItemState extends State<ReusableListItem> {
  // var pill;
  // ignore: unused_element
  // _ReusableListItemState({Key? key}) : super();
  final List<Color> _color = [];

  @override
  void initState() {
    super.initState();
    setState(() {});
    _color;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pill.toString().contains("null")) {
      return Row();
    }

    String index = widget.pill.split(",")[0];
    String content = widget.pill.split(",")[1];
    String icons = widget.pill.split(",")[2];
    String scaleId = widget.pill.split(",")[3];

    while (
        (int.parse(index) >= int.parse(myDevicedata.color.length.toString()))) {
      myDevicedata.color.add(Colors.transparent);
    }

    if (icons == "") {
      return Row();
    }
    return Container(
      decoration: const BoxDecoration(
          //背景
          // color: Colors.white,
          //设置四周圆角 角度
          // borderRadius: BorderRadius.all(Radius.circular(20)),
          //设置四周边框
          // border: new Border.all(width: 1, color: Colors.red),
          ),
      margin: const EdgeInsets.all(1),
      child: Center(
          child: Container(
              decoration:
                  BoxDecoration(color: myDevicedata.color[int.parse(index)]),
              child: Row(
                children: [
                  (icons == "Icons.usb")
                      ? const Icon(Icons.usb, color: Color(0xff006e1a))
                      : (icons == "Icons.usb_off")
                          ? Icon(Icons.usb, color: Colors.red.shade900)
                          : (icons == "Icons.device_unknown")
                              ? const Icon(Icons.device_unknown,
                                  color: Color.fromARGB(255, 240, 133, 0))
                              : (icons == "Icons.wifi")
                                  ? Icon(Icons.wifi,
                                      color: Colors.blue.shade900)
                                  : Icon(Icons.bluetooth,
                                      color: Colors.blue.shade900),
                  SizedBox(
                    width: 135,
                    height: 50,
                    child: MaterialButton(
                      // splashColor: Color(0xff004a98),
                      // highlightColor: Colors.yellowAccent,
                      hoverColor: const Color(0xFFD7E3FF),
                      focusColor: const Color(0xFFD7E3FF),
                      onPressed: () {
                        setState(() {
                          while ((int.parse(index) >=
                              int.parse(_color.length.toString()))) {
                            _color.add(Colors.transparent);
                          }

                          // for (var i = 0; i <= int.parse(index) + 1; i++) {
                          //   _color.add(Colors.transparent);
                          //   // _color[i] = Colors.transparent;
                          // }

                          _color[int.parse(index)] = const Color(0xFFD7E3FF);
                          myDevicedata.color = _color;
                          myDevicedata.name = content;
                          myDevicedata.type = icons;
                          myDevicedata.index = index;
                          myDevicedata.scaleID = scaleId;

                          for (var i = 0;
                              i < myComScaleList.comScaleList.length;
                              i++) {
                            var tmpScaleId = myComScaleList
                                .comScaleList[i].scaleId
                                .toString();
                            if (tmpScaleId == myDevicedata.scaleID) {
                              myCurrentPort.baud =
                                  myComScaleList.comScaleList[i].baudRate;
                              myCurrentPort.dataBits =
                                  myComScaleList.comScaleList[i].dataBits;
                              myCurrentPort.devPath =
                                  myComScaleList.comScaleList[i].portName;
                              myCurrentPort.parity =
                                  myComScaleList.comScaleList[i].parity;
                              myCurrentPort.stopBits =
                                  myComScaleList.comScaleList[i].stopBits;
                              myDevicedata.mediaType =
                                  myComScaleList.comScaleList[i].tMedia;
                              myDevicedata.scaleSn =
                                  myComScaleList.comScaleList[i].scaleSn;
                            }
                          }
                          eventBus.fire(EventDeviceName(myDevicedata));

                          eventBus.fire(EventCurrentPort(myCurrentPort));
                        });
                      },
                      child: (index == myDevicedata.index)
                          ? Text(
                              content,
                              style: const TextStyle(
                                  color: Color(0xff004a98), //字体颜色
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )
                          : Text(
                              content,
                              style: const TextStyle(
                                fontSize: 18,
                                // color: Colors.white, //字体颜色
                                fontWeight: FontWeight.bold, //字体粗细
                              ),
                            ),
                    ),
                  ),
                  // const SizedBox(
                  //   width: 5,
                  //   height: 30,
                  // ),
                  SizedBox(
                      width: 35,
                      height: 50,
                      child: (index == myDevicedata.index)
                          ? MaterialButton(
                              onPressed: () {
                                if (index == myDevicedata.index) {
                                  print("OK");
                                } else {
                                  print("false");
                                }
                              },
                              child: (index == myDevicedata.index)
                                  ? const Icon(Icons.clear,
                                      color: Color(0xff004a98))
                                  : const Icon(Icons.clear, color: Colors.grey),
                              padding: const EdgeInsets.all(5),
                            )
                          : const Text(
                              " ",
                              style: TextStyle(
                                fontSize: 18,
                                // color: Colors.white, //字体颜色
                                fontWeight: FontWeight.bold, //字体粗细
                              ),
                            )),
                  // const SizedBox(
                  //   width: 5,
                  //   height: 30,
                  // ),
                ],
              ))),
    );
  }
}

/*
import 'package:flutter/material.dart';

import '../../data/device_data.dart';
import '../../eventbus/eventbus.dart';

// ignore: must_be_immutable
class ReusableListItem extends StatefulWidget {
  ReusableListItem(this.pill, {Key? key}) : super(key: key);
  late String pill;
  @override
  State<ReusableListItem> createState() => _ReusableListItemState(this.pill);
}

// late int connectionType;
class _ReusableListItemState extends State<ReusableListItem> {
  var pill;
  // ignore: unused_element
  _ReusableListItemState(this.pill, {Key? key}) : super();
  final List<Color> _color = [
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent
  ];

  @override
  void initState() {
    super.initState();
    _color;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pill.toString().contains("null")) {
      return Row();
    }

    String index = pill.split(",")[0];
    String content = pill.split(",")[1];
    String icons = pill.split(",")[2];
    if (icons == "") {
      return Row();
    }
    return Container(
      margin: const EdgeInsets.all(1),
      child: Center(
          child: Container(
              decoration:
                  BoxDecoration(color: myDevicedata.color[int.parse(index)]),
              child: Row(
                children: [
                  (icons == "Icons.usb")
                      ? Icon(Icons.usb, color: Colors.blue.shade900)
                      : (icons == "Icons.wifi")
                          ? Icon(Icons.wifi, color: Colors.blue.shade900)
                          : Icon(Icons.bluetooth, color: Colors.blue.shade900),
                  SizedBox(
                    width: 145,
                    height: 20,
                    child: MaterialButton(
                        onPressed: () {
                          setState(() {
                            for (var i = 0; i < int.parse(index); i++) {
                              _color.add(Colors.transparent);
                              // _color[i] = Colors.transparent;
                            }

                            _color[int.parse(index)] = Colors.blue;
                            myDevicedata.color = _color;
                            myDevicedata.name = content;
                            myDevicedata.type = icons;
                            myDevicedata.index = index;
                            eventBus.fire(EventDeviceName(myDevicedata));
                          });
                        },
                        child: Text(content)),
                  ),
                  SizedBox(
                    width: 25,
                    height: 20,
                    child: MaterialButton(
                        onPressed: () {},
                        child: Icon(Icons.clear, color: Colors.grey)),
                  ),
                ],
              ))),
    );
  }
}


 */
