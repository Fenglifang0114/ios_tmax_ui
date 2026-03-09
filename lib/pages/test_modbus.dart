import 'package:flutter/material.dart';

import 'package:t_max/data/readoutput.dart';
import 'package:t_max/functions/methods.dart';

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TestModbus extends StatefulWidget {
  const TestModbus({super.key});

  @override
  TestModbusState createState() => TestModbusState();
}

class TestModbusState extends State<TestModbus>
    with TrayListener, WindowListener {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景图

          SizedBox(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 0, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("0")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 0, status: true);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写0 开")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 1, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("1")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 0, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写0 关")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 2, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("2")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 2, status: true);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写2")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 3, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("3")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 3, status: true);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写3")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 4, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("4")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 4, status: true);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写4")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 5, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("5")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 5, status: true);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写5")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 6, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("6")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 6, status: true);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写6")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 7, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("7")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 7, status: true);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写7")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 8, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("8")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 8, status: true);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写8")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 9, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("9")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 9, status: true);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写9")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 10, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("10")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 10, status: true);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写10")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 11, status: false);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.readModbusCoils(jsonStr);
                          },
                          child: Text("11")),
                      TextButton(
                          onPressed: () {
                            ReqPortInfo reqPortInfo =
                                ReqPortInfo(portId: 11, status: true);
                            String jsonStr = reqPortInfoToJson(reqPortInfo);
                            PublicFunctions.writeModbusCoils(jsonStr);
                          },
                          child: Text("写11")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            PublicFunctions.getOutputPortStatus();
                          },
                          child: Text("读取设置状态")),
                      TextButton(
                          onPressed: () {
                            ReqGetOutput reqGetOutput = ReqGetOutput(
                                port: 1,
                                status: true,
                                startTime: 10,
                                endValue: 10.0);

                            String jsonStr = reqGetOutputToJson(reqGetOutput);
                            PublicFunctions.updateOutputPortStatus(jsonStr);
                          },
                          child: Text("写11")),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
