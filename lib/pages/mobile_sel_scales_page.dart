import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/functions/methods.dart';
import '../../eventbus/eventbus.dart';
import '../data/comscaleinfo_data.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../data/home_page_common_data.dart';
import '../data/scale_info_from_db.dart';
import '../usb_serial_manager.dart';
import 'update_firmware_page.dart'; // For normalSend, sendServerIp, sendOnline, ScaleDownRes

class MobileSelectScalesPage extends StatefulWidget {
  final int funcNo;
  final String sendMsgStr;
  final List<String>? jsonList;
  const MobileSelectScalesPage({
    required this.funcNo,
    required this.sendMsgStr,
    this.jsonList,
    super.key,
  });

  @override
  State<MobileSelectScalesPage> createState() => _MobileSelectScalesPageState();
}

class _MobileSelectScalesPageState extends State<MobileSelectScalesPage> {
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  dynamic _eventbus9;
  dynamic _eventbus10;
  dynamic _eventbus11;
  dynamic _eventbus12;

  Map<int, bool> checkboxStatesMap = {};
  Map<int, ScaleDownRes> scaleResMap = {};
  Map<int, Timer?> scaleTimerMap = {};

  bool isDownloading = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    for (var item in myAllScalesList) {
      checkboxStatesMap[item.scaleId!] = false;
    }

    _eventbus1 = eventBus.on<EventDownPrnFmtResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }
          if (checkAllNotEmpty()) isDownloading = false;
        });
      }
    });

    _eventbus2 = eventBus.on<EventDownDefPrnFmtResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }
          if (checkAllNotEmpty()) isDownloading = false;
        });
      }
    });

    _eventbus3 = eventBus.on<EventRespDownPlu>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }
          if (checkAllNotEmpty()) isDownloading = false;
        });
      }
    });

    _eventbus4 = eventBus.on<EventRespInsertPlu>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }
          if (checkAllNotEmpty()) isDownloading = false;
        });
      }
    });

    _eventbus5 = eventBus.on<EventModifyVarValueResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }
          if (checkAllNotEmpty()) isDownloading = false;
        });
      }
    });

    _eventbus6 = eventBus.on<EventRespCheckNetScale>().listen((event) {});

    _eventbus7 = eventBus.on<EventSetServerIPResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }
          if (checkAllNotEmpty()) isDownloading = false;
        });
      }
    });

    _eventbus8 = eventBus.on<EventUpdateFirmWareNetResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }
          if (checkAllNotEmpty()) isDownloading = false;
        });
      }
    });

    _eventbus9 = eventBus.on<EventRespScaleOnline>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });

    _eventbus10 = eventBus.on<EventRespUpdateFirmware>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        setState(() {
          if (myRespDataFromScale.msgBody.contains('fail')) {
            scaleTimerMap[myRespDataFromScale.scaleId]?.cancel();
            UsbSerialManager().restoreBaudRate();
          }

          if (scaleResMap[myRespDataFromScale.scaleId] != null && !scaleResMap[myRespDataFromScale.scaleId]!.res.contains('ok')) {
            scaleResMap[myRespDataFromScale.scaleId]!.res = myRespDataFromScale.msgBody;
            if (myRespDataFromScale.msgBody.contains('ok') || myRespDataFromScale.msgBody.contains('OK')) {
              UsbSerialManager().restoreBaudRate();
            }
          }

          if (checkAllNotEmpty()) isDownloading = false;
        });
      }
    });

    _eventbus11 = eventBus.on<EventRespUpdateFirmwareProcess>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok') || myRespDataFromScale.msgBody.contains('fail')) {
          setState(() {
            if (scaleResMap[myRespDataFromScale.scaleId] != null && !scaleResMap[myRespDataFromScale.scaleId]!.res.contains('ok')) {
              scaleResMap[myRespDataFromScale.scaleId]!.res = myRespDataFromScale.msgBody;
            }
            if (checkAllNotEmpty()) isDownloading = false;
          });
        } else {
          if (myRespDataFromScale.msgBody.contains('completed')) {
            updateProgress(100, myRespDataFromScale.scaleId);
            return;
          }

          if (int.tryParse(myRespDataFromScale.msgBody) != null) {
            int numericValue = int.parse(myRespDataFromScale.msgBody);
            if (numericValue <= 100) numericValue = (numericValue).toInt();
            updateProgress(numericValue, myRespDataFromScale.scaleId);
          } else {
            setState(() {
              if (scaleResMap[myRespDataFromScale.scaleId] != null && !scaleResMap[myRespDataFromScale.scaleId]!.res.contains('ok')) {
                scaleResMap[myRespDataFromScale.scaleId]!.res = myRespDataFromScale.msgBody;
              }
            });
          }
        }
      }
    });

    _eventbus12 = eventBus.on<EventSerialOutputResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }
          if (checkAllNotEmpty()) isDownloading = false;
        });
      }
    });
  }

  void updateProgress(int value, int scaleId) {
    setState(() {
      _progress = value.toDouble() / 100;
      if (scaleResMap[scaleId] != null) {
        scaleResMap[scaleId]!.process = _progress;
        if (scaleResMap[scaleId]!.res != '' && scaleResMap[scaleId]!.res != 'ok') {
          scaleResMap[scaleId]!.res = '';
        }
      }
    });
  }

  void parseRecInfo(int scaleId) {
    if (scaleResMap.containsKey(scaleId)) {
      scaleTimerMap[scaleId]?.cancel();
      if (myRespDataFromScale.msgBody.contains('ok')) {
        scaleResMap[scaleId]!.process = 1;
      }
      scaleResMap[scaleId]!.res = myRespDataFromScale.msgBody;
    }
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    _eventbus9.cancel();
    _eventbus10.cancel();
    _eventbus11.cancel();
    _eventbus12.cancel();

    if (scaleTimerMap.isNotEmpty) {
      scaleTimerMap.forEach((int key, Timer? timer) {
        timer?.cancel();
      });
    }
    UsbSerialManager().restoreBaudRate();
    super.dispose();
  }

  bool checkAllNotEmpty() {
    for (var value in scaleResMap.values) {
      if (value.res.isEmpty) return false;
    }
    return true;
  }

  void buildProcessTimer(int downTime) {
    scaleResMap.forEach((int id, ScaleDownRes value) {
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (scaleResMap[id]!.res != "" && !scaleResMap[id]!.res.startsWith("Step:")) {
          scaleResMap[id]!.process = 1;
          timer.cancel();
        } else if (scaleResMap[id]!.process < 0.9) {
          setState(() {
            scaleResMap[id]!.process += 0.9 / downTime;
          });
        }
      });
      scaleTimerMap[id] = timer;
    });
  }

  bool checkSelect() {
    scaleResMap.clear();
    if (checkboxStatesMap.isEmpty) return false;

    checkboxStatesMap.forEach((scaleId, selected) {
      if (selected) {
        scaleResMap[scaleId] = ScaleDownRes(scaleId, '', 0.0);
      }
    });
    return scaleResMap.isNotEmpty;
  }

  void performSend() {
    scaleResMap.forEach((key, value) {
      sendMessage(key);
    });
    buildProcessTimer(240);
  }

  void sendMessage(int scaleId) {
    if (widget.funcNo == normalSend) {
      PublicFunctions.sendMsg(scaleId, widget.sendMsgStr);
    } else if (widget.funcNo == sendServerIp) {
      PublicFunctions.sendServerIpToScale(widget.sendMsgStr, scaleId);
    } else if (widget.funcNo == sendOnline) {
      PublicFunctions.updateFirmWareOnline(widget.sendMsgStr, scaleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: Colors.black87,
          onPressed: () {
             PublicFunctions.killBootCommander();
             Navigator.pop(context);
          },
        ),
        title: Text(
          widget.funcNo == sendOnline
              ? (localizedStrings?.menuFirmwareUpdate ?? "Firmware Update")
              : (localizedStrings?.gBtnDownload ?? "Download"),
          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: myAllScalesList.length,
              itemBuilder: (context, index) {
                var scale = myAllScalesList[index];
                int id = scale.scaleId!;
                bool isSelected = checkboxStatesMap[id] ?? false;
                bool isOnline = scale.isOnline ?? false;
                ScaleDownRes? resInfo = scaleResMap[id];
                double progress = resInfo?.process ?? 0.0;
                String resStr = resInfo?.res ?? "";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isOnline ? (localizedStrings?.gTipOnline ?? "online") : (localizedStrings?.gTipOffline ?? "Offline"),
                            style: TextStyle(
                              color: isOnline ? Colors.blue[700] : Colors.red[500],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: isSelected,
                              onChanged: isDownloading ? null : (val) {
                                setState(() {
                                  checkboxStatesMap[id] = val ?? false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(localizedStrings?.gScaleName ?? "Scale Name", scale.scaleName ?? ""),
                      const SizedBox(height: 8),
                      _buildInfoRow((localizedStrings?.gModelName ?? "Model Name") + "/Sn", "${scale.scaleModel == 'TMax' ? '' : scale.scaleModel}/${scale.scaleSn}"),
                      const SizedBox(height: 8),
                      _buildInfoRow("Ip/Port", _getScaleIpPort(scale)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizedStrings?.gTipResult ?? "Result",
                            style: const TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          Text(
                            resStr,
                            style: TextStyle(
                              color: resStr.contains('ok') || resStr.contains('OK') ? Colors.green : Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          resStr.contains('ok') || resStr.contains('OK') ? Colors.green : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: (!isDownloading && checkSelect()) ? () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 8, top: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      localizedStrings?.fTipTitle ?? "Tip",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.black54),
                                      onPressed: () => Navigator.pop(context, false),
                                    ),
                                  ],
                                ),
                              ),
                              // Image
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Image.asset(
                                  'assets/images/person.png',
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              // Text
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  localizedStrings?.gTipConfirmContinue ?? "Please confirm to continue.",
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1CB079), // Green color matching design
                                    foregroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    localizedStrings?.gBtnConfirm ?? "Confirm",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).then((value) {
                      if (value == true) {
                        PublicFunctions.killBootCommander();
                        setState(() {
                          isDownloading = true;
                          for (var entry in scaleResMap.entries) {
                            entry.value.res = "";
                            scaleResMap[entry.key]!.process = 0;
                          }
                        });
                        performSend();
                      }
                    });
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) return Colors.grey[400]!;
                        return const Color(0xFF0D558E); 
                      },
                    ),
                  ),
                  child: Text(
                    localizedStrings?.gBtnStart ?? "Start",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ],
    );
  }

  String _getScaleIpPort(Scale scale) {
    String addr = "";
    String port = "";
    if (scale.tMedia == comScaleType) {
      addr = (scale.mediaConfig as SerialMediaConfig).devPath;
      port = (scale.mediaConfig as SerialMediaConfig).baudRate.toString();
    } else if (scale.tMedia == netScaleType) {
      addr = (scale.mediaConfig as NetworkMediaConfig).ipAddress;
      port = (scale.mediaConfig as NetworkMediaConfig).port.toString();
    } else if (scale.tMedia == btScaleType) {
      addr = (scale.mediaConfig as BluetoothMediaConfig).mac;
      port = (scale.mediaConfig as BluetoothMediaConfig).name;
    }
    return "$addr/$port";
  }
}
