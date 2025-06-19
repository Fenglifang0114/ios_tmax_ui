import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/data/writelog.dart';
import 'package:t_max/dialog/app_common_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/no_device_widget.dart';
import '../data/cominfoslist_data.dart';
import '../data/device_data.dart';
import '../data/downloadresponse.dart';
import '../data/ipinfodata.dart';
import '../data/language.dart';
import '../data/manager_scale_channel.dart';
import '../data/modifyresult_data.dart';
import '../data/modifyscale_data.dart';
import '../data/scale_info_from_scale.dart';
import '../data/scalelist_data.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import '../widget/page_head.dart';

class MultiScaleManagement extends StatefulWidget {
  const MultiScaleManagement({super.key});

  @override
  State<MultiScaleManagement> createState() => MultiScaleManagementState();
}

class MultiScaleManagementState extends State<MultiScaleManagement> {
  List<int> wifiRssiList = [];
  List<String> bssidList = [];

  TextEditingController scaleModelCtl = TextEditingController(text: '');
  TextEditingController scaleNameCtl = TextEditingController(text: '');
  TextEditingController snCtl = TextEditingController(text: '');
  TextEditingController portCtl = TextEditingController(text: '');
  TextEditingController ipCtl = TextEditingController(text: '');
  TextEditingController dataBitCtl = TextEditingController(text: '8');
  TextEditingController stopBitCtl = TextEditingController(text: '1');
  TextEditingController comPortCtl = TextEditingController(text: '');
  TextEditingController baudRateCtl = TextEditingController(text: '115200');
  TextEditingController protocolCtl = TextEditingController(text: 'None');

  int selScaleId = -1;

  bool isAddScale = false;
  String addScaleType = '';
  bool isTesting = false;
  bool isRename = false;
  bool _isValidIP = false;
  bool _isModifyName = false;
  bool _isEditing = false;
  bool _isNetPort = false;
  bool isDel = false; //是否执行删除

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  dynamic _eventbus9;
  // dynamic _eventbus10;

  Timer? checkIsOnlineTimer;
  List<String> comLists = [];
  List<String> usingComLists = [];

  List<String> baudRateList = [
    '115200',
    '57600',
    '38400',
    '19200',
    '14400',
    '9600',
    '4800',
  ];
  List<String> scaleModelList = ['TMax'];
  String scaleModel = myModifyScale.scaleModel.toString();
  List<String> dataBitsList = ['8']; //去掉5,6,7,8
  List<String> stopBitsList = ['1']; //, '1.5', '2'
  List<String> checkBitsList = ['None']; //, 'Odd', 'Even'
  //'Xon/Xoff', 'None', 'Rts/Cts', 'Dsr/Dtr'
  String dialogtype = "com";
  String serialPortConnect = " ";
  bool isComSetting = false;
  bool isClosePort = true;

  RegExp ipRegex = RegExp(
    r'^((\d{1,3}\.){3}\d{1,3})$',
    multiLine: false,
    caseSensitive: false,
  );

  bool _isValidIpAddress(bool tempValid, String value) {
    if (tempValid) {
      List<int?> parts = value.split('.').map(int.tryParse).toList();
      if (parts.any((part) => part == null || part > 255)) {
        tempValid = false;
      }
    }
    return tempValid;
  }

  @override
  void initState() {
    super.initState();
    initScaleList();
    initEventBus();
    PublicFunctions.getPortList();

    checkPortList();

    scaleNameCtl.addListener(_onScaleNameChanged);
    ipCtl.addListener(_onIpChanged);
    portCtl.addListener(_onPortChanged);
  }

  void initScaleList() {}

  void initEventBus() {
    _eventbus1 = eventBus.on<EventRespDelScale>().listen((event) {
      if (mounted) {
        setState(() {
          String dataStr = event.obj;
          if (dataStr.isNotEmpty) {
            dataStr.contains('ok')
                ? showTipInfo(localizedStrings.fSuccessMsg, context)
                : showTipInfo(dataStr, context);
            if (dataStr.contains('ok') && isDel) {
              PublicFunctions.getScaleList();
              isDel = false;
            }
          }
        });
      }
    });

    _eventbus2 = eventBus.on<EventRespAddScale>().listen((event) {
      if (mounted) {
        setState(() {
          isAddScale = false;
          String dataStr = event.obj;
          if (dataStr.isNotEmpty) {
            dataStr.contains('ok')
                ? showTipInfo(localizedStrings.fSuccessMsg, context)
                : showTipInfo(dataStr, context);
          }

          for (int i = 0; i < myNetScaleList.length; i++) {
            if (selScaleId < myNetScaleList[i].scaleId!) {
              selScaleId = myNetScaleList[i].scaleId!;
              scaleNameCtl.text = myNetScaleList[i].scaleName!;
              scaleModelCtl.text = myNetScaleList[i].scaleModel!;
              snCtl.text = myNetScaleList[i].scaleSn!;
            }
          }
          if (scaleModelCtl.text == "TMax") {
            scaleModelCtl.text = "";
            snCtl.text = "";
          }
        });
      }
    });

    _eventbus3 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        myOnlineInfo = event.obj;
        myFactoryInfoFromScale = myOnlineInfo.factInfo!;
        setState(() {
          if (myFactoryInfoFromScale.modelName != '') {
            setScaleStatus(myOnlineInfo.scaleId!, true);
            if (isTesting) {
              showTipInfo(localizedStrings.fSuccessMsg, context);
            }
          } else {
            setScaleStatus(myOnlineInfo.scaleId!, false);
            if (isTesting) {
              showTipInfo(localizedStrings.gTipConnectFail, context);
            }
          }
          if (isTesting) {
            isTesting = false;
          }
        });
      }
    });
    _eventbus4 = eventBus.on<EventRespScaleOnline>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });

    _eventbus5 = eventBus.on<EventSerialPortResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;

          if (myComScaleInfo.isOnline) {
            myComScaleInfo.isOnline = false;
            showTipInfo(localizedStrings.gTipSerialPortDisconnected, context);
          }
          myComScaleInfo.isOnline = false;
          myComScaleSn.modelName = '';
          myComScaleSn.scaleSn = '';
          myComScaleInfo.isOnline = false;
        });
      }
    });

    _eventbus6 = eventBus.on<EventRespScaleModify>().listen((event) {
      if (mounted) {
        myModifyAck = event.obj;
        isComSetting = false;
        PublicFunctions.checkSerialPort(selScaleId);
        isTesting = true;
      }
    });

    _eventbus7 = eventBus.on<EventComInfoList>().listen((event) {
      if (mounted) {
        setState(() {
          myComInfoList = event.obj;
          checkPortList();
        });
      }
    });

    _eventbus8 = eventBus.on<EventDeviceName>().listen((event) {
      if (mounted) {
        setState(() {
          myDevicedata = event.obj;
        });
      }
    });
    _eventbus9 = eventBus.on<EventCurrentPort>().listen((event) {
      if (mounted) {
        setState(() {
          myCurrentPort = event.obj;
        });
      }
    });
  }

  void _onPortChanged() {
    if (portCtl.text.isEmpty) {
      if (_isNetPort) {
        setState(() {
          _isNetPort = false;
        });
      }
      return;
    }

    if (_isNetPort != true) {
      setState(() {
        _isNetPort = true;
      });
    }
  }

  void _onIpChanged() {
    if (ipCtl.text.isEmpty) {
      if (_isValidIP) {
        setState(() {
          _isValidIP = false;
        });
      }
      return;
    }
    bool isValid = validateIpFlag(ipCtl.text);
    if (isValid != _isValidIP) {
      setState(() {
        _isValidIP = isValid;
      });
    }
  }

  void _onScaleNameChanged() {
    if (scaleNameCtl.text.isNotEmpty) {
      bool isValid = isValidScaleName(scaleNameCtl.text);
      if (_isModifyName != isValid) {
        setState(() {
          _isModifyName = isValid;
        });
      }
    } else {
      if (_isModifyName) {
        setState(() {
          _isModifyName = false;
        });
      }
    }
  }

  void setScaleStatus(int scaleId, bool status) {
    for (int i = 0; i < myAllScalesList.length; i++) {
      if (scaleId == myAllScalesList[i].scaleId) {
        setState(() {
          myAllScalesList[i].isOnline = status;
          if (selScaleId == scaleId) {
            scaleModelCtl.text = myAllScalesList[i].scaleModel;
            snCtl.text = myAllScalesList[i].scaleSn;
          }
          if ((scaleModelCtl.text == 'T-Max' || scaleModelCtl.text == 'TMax') &&
              snCtl.text.length == 10 &&
              snCtl.text.startsWith('174')) {
            scaleModelCtl.text = '';
            snCtl.text = '';
          }
        });
      }
    }
  }

  // void setNetScaleStatus(int scaleId, bool status) {
  //   for (int i = 0; i < scaleNetItems.length; i++) {
  //     if (scaleNetItems[i].scaleId == scaleId) {
  //       scaleNetItems[i].isOnline = status;
  //     }
  //   }
  // }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    _eventbus9.cancel();
    _eventbus6.cancel();

    scaleNameCtl.dispose();
    ipCtl.dispose();
    portCtl.dispose();
    comPortCtl.dispose();
    baudRateCtl.dispose();
    protocolCtl.dispose();
    dataBitCtl.dispose();
    stopBitCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;
    tempCurrentPort = myCurrentPort;

    return Scaffold(
        body: isAddScale && addScaleType != ""
            ? showAddScaleInfo(maxWidth)
            : showNormalScaleInfo(maxWidth));
  }

//正常显示
  Widget showNormalScaleInfo(double maxWidth) {
    return Column(children: [
      // pageHeadInfo(
      //     context,
      //     maxWidth - headWidthPadding,
      //     localizedStrings.menuMultiScaleManagement,
      //     localizedStrings.gTipScaleMgrPageHelp),
      Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: scaleListWidth,
          color: Theme.of(context).colorScheme.surfaceTint,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: regularPadding,
                ),
                showAddScaleBtn(),
                Expanded(child: showScaleList(scaleListWidth))
              ],
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant, // 蓝色分隔条颜色
              ),
              selScaleId == -1
                  ? SizedBox()
                  : getScaleType() == comScaleType
                      ? showSerialScaleInfo()
                      : showDetailScaleInfo(), //网络秤
            ],
          ),
        ),
      ]))
    ]);
  }

  int getScaleType() {
    //检查是不是串口的秤
    for (int i = 0; i < myAllScalesList.length; i++) {
      if (selScaleId == myAllScalesList[i].scaleId) {
        return myAllScalesList[i].tMedia;
      }
    }
    return 0;
  }

//增加秤时显示
  Widget showAddScaleInfo(double maxWidth) {
    return Column(children: [
      subTitleInfo(context, maxWidth - headWidthPadding,
          localizedStrings.gBtnAdd, localizedStrings.gTipScaleMgrPageHelp),
      Expanded(
        child: addScaleType == "com"
            ? showAddComScaleInfo()
            : showAddNetScaleInfo(),
      ),
    ]);
  }

  Widget showAddComScaleInfo() {
    return ListView(
      children: [
        SizedBox(
          height: regularPadding,
        ),
        buildItemInfo(
            showItemName(context, localizedStrings.gSerialPort, false),
            showDropDownButton(
              context,
              localizedStrings.gTipRefreshPort,
              comPortCtl,
              usingComLists,
              (value) {
                setState(() {
                  if (value != null && comLists.contains(value)) {
                    comPortCtl.text = value;
                  } else {
                    // 若选择的值不在 comLists 中，清空输入框
                    comPortCtl.clear();
                  }
                  usingComLists = List<String>.from(comLists);
                });
              },
              onTap: () {
                PublicFunctions.getPortList();
                if (comLists.isEmpty && comPortCtl.text.isNotEmpty) {
                  comPortCtl.clear();
                }
              },
            ),
            showItemName(context, localizedStrings.gBaudRate, false),
            showDropDownButton(context, '', baudRateCtl, baudRateList, (value) {
              setState(() {
                if (baudRateList.contains(value)) {
                  baudRateCtl.text = value!;
                }
              });
            })),
        buildItemInfo(
            showItemName(context, localizedStrings.gSerialParity, false),
            showDropDownButton(context, '', protocolCtl, checkBitsList,
                (value) {
              setState(() {
                if (checkBitsList.contains(value)) {
                  protocolCtl.text = value!;
                }
              });
            }),
            showItemName(context, localizedStrings.gStopBits, false),
            showDropDownButton(context, '', stopBitCtl, stopBitsList, (value) {
              setState(() {
                if (stopBitsList.contains(value)) {
                  stopBitCtl.text = value!;
                }
              });
            })),
        buildItemInfo(
            showItemName(context, localizedStrings.gDataBits, false),
            showDropDownButton(context, '', dataBitCtl, dataBitsList, (value) {
              setState(() {
                if (dataBitsList.contains(value)) {
                  dataBitCtl.text = value!;
                }
              });
            }),
            SizedBox(
              width: inputWidth,
            ),
            SizedBox(
              width: inputWidth,
            )),
        SizedBox(
          height: regularPadding,
        ),
        SizedBox(
          height: regularPadding,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showTextButton(
                context,
                btnHeight,
                localizedStrings.gBtnConfirm,
                comPortCtl.text.isNotEmpty
                    ? () {
                        for (var scale in myAllScalesList) {
                          if (scale.tMedia == comScaleType) {
                            final serialConfig =
                                scale.mediaConfig as SerialMediaConfig;
                            if (serialConfig.devPath == comPortCtl.text) {
                              showTipInfo(
                                  localizedStrings.gTipPortInUsed +
                                      scale.scaleName,
                                  context);
                              return;
                            }
                          }
                        }
                        isAddScale = false;
                        isRename = false;
                        addScaleType = '';

                        addComScale();
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: regularPadding),
            showTextButton(context, btnHeight, localizedStrings.gBtnCancel, () {
              setState(() {
                isAddScale = false;
                isRename = false;
                addScaleType = '';
                selScaleId = -1;
                if (isComSetting) {
                  isComSetting = false;
                }
              });
            },
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.onSurfaceVariant,
                Theme.of(context).colorScheme.onPrimary),
          ],
        )
      ],
    );
  }

  Widget showAddNetScaleInfo() {
    return ListView(
      children: [
        SizedBox(
          height: regularPadding,
        ),
        buildItemInfo(
            showItemName(context, localizedStrings.gIpAddress, false),
            showInputBox(context, ipCtl, '', (value) {
              setState(() {});
            }, true),
            showItemName(context, localizedStrings.gTipPort, false),
            Container(
              height: inputHeight,
              padding: const EdgeInsets.only(left: 16, right: 20),
              decoration: BoxDecoration(
                border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
                borderRadius: BorderRadius.circular(0), // 设置圆角
              ),
              child: TextField(
                controller: portCtl,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, // 设置提示文本颜色
                  ),
                  border: InputBorder.none, // 移除默认边框
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.allow(RegExp(
                      r'^([1-9]|[1-9]\d|[1-9]\d{2}|[1-9]\d{3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$')), // 允许输入数字
                ],
                style: Theme.of(context).textTheme.bodySmall!.apply(
                      color:
                          Theme.of(context).colorScheme.onSurface, // 设置输入文本颜色
                    ),
                onChanged: (value) {
                  setState(() {});
                }, // 监听文本变化,
              ),
            )),
        SizedBox(
          height: regularPadding,
        ),
        SizedBox(
          height: regularPadding,
        ),
        SizedBox(
          height: regularPadding,
        ),
        SizedBox(
          height: regularPadding,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showTextButton(
                context,
                btnHeight,
                localizedStrings.gBtnConfirm,
                portCtl.text.isNotEmpty && _isValidIP
                    ? () {
                        isAddScale = false;
                        isRename = false;
                        addScaleType = '';

                        addNetScale();
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: regularPadding),
            showTextButton(context, btnHeight, localizedStrings.gBtnCancel, () {
              setState(() {
                isAddScale = false;
                isRename = false;
                addScaleType = '';
                selScaleId = -1;

                if (isComSetting) {
                  isComSetting = false;
                }
              });
            },
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.onSurfaceVariant,
                Theme.of(context).colorScheme.onPrimary),
          ],
        )
      ],
    );
  }

  Widget showAddScaleBtn() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: regularPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: textColorBtn(
                context,
                Theme.of(context).colorScheme,
                Theme.of(context).textTheme,
                isTesting || isRename || isDel || isComSetting || isAddScale
                    ? null
                    : () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AddScaleDialog();
                          },
                        ).then((value) {
                          if (value != "") {
                            setState(() {
                              addScaleType = value;
                              isAddScale = true;
                              selScaleId = -1;
                              isRename = false;
                              isAddScale = true;
                              ipCtl.text = "";
                              snCtl.text = "";
                              portCtl.text = "";
                            });
                          }
                        });
                      },
                localizedStrings.gBtnAdd,
                btnHeight,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: textColorBtn(
                context,
                Theme.of(context).colorScheme,
                Theme.of(context).textTheme,
                (isAddScale || isTesting) || isRename || isDel
                    ? null
                    : () {
                        setState(() {
                          isDel = true;
                          delScale();
                        });
                      },
                localizedStrings.gBtnDelete,
                btnHeight,
                Theme.of(context).colorScheme.error,
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ));
  }

  showScaleList(double listWidth) {
    return AnimatedContainer(
      color: Theme.of(context).colorScheme.surface,
      width: listWidth,
      duration: Duration(milliseconds: 300),
      child: Column(
        children: [
          SizedBox(
            height: regularPadding,
          ),
          SizedBox(
            height: smallPadding,
          ),
          myAllScalesList.isEmpty
              ? showNoDeviceWidget(context)
              : showAllDevicesWidget()
        ],
      ),
    );
  }

  Widget showAllDevicesWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: ListView.separated(
          itemCount: myAllScalesList.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: smallPadding),
          itemBuilder: (context, index) {
            final scale = myAllScalesList[index];
            bool isSelect = (scale.scaleId == selScaleId);
            return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isRename = false;
                        selScaleId = scale.scaleId;
                        scaleNameCtl.text = scale.scaleName;
                        scaleModelCtl.text = scale.scaleModel;
                        snCtl.text = scale.scaleSn;
                        // 判断 scaleModel 是否为 TMax，且 sn 是否为 10 位并以 174 开头

                        if (scale.tMedia == comScaleType) {
                          final serialConfig =
                              scale.mediaConfig as SerialMediaConfig;
                          comPortCtl.text = serialConfig.devPath;
                          dataBitCtl.text = serialConfig.dataBits.toString();
                          baudRateCtl.text = serialConfig.baudRate.toString();
                          usingComLists = List<String>.from(comLists);
                          if (!comLists.contains(comPortCtl.text)) {
                            comPortCtl.text = '';
                          }
                        } else {
                          final netConfig =
                              scale.mediaConfig as NetworkMediaConfig;
                          ipCtl.text = netConfig.ipAddress;
                          portCtl.text = netConfig.port.toString();
                        }
                        if ((scale.scaleModel == 'T-Max' ||
                                scale.scaleModel == 'TMax') &&
                            scale.scaleSn.length == 10 &&
                            scale.scaleSn.startsWith('174')) {
                          scaleModelCtl.text = '';
                          snCtl.text = '';
                        }
                      });
                    },
                    child: Container(
                      height: scaleItemHeight,
                      color: !isSelect
                          ? Theme.of(context).colorScheme.surfaceContainerLow
                          : scale.isOnline
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                      child: Row(
                        children: [
                          Container(
                              width: scaleItemHeight,
                              height: scaleItemHeight,
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  color: !isSelect
                                      ? Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerLowest
                                      : Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withOpacity(0.1),
                                ),
                                width: scaleInnerItemHeight,
                                height: scaleInnerItemHeight,
                                child: scale.tMedia == 0
                                    ? Container(
                                        alignment: Alignment.center,
                                        width: iconMenuSize,
                                        height: iconMenuSize,
                                        child: getSvgIcon(
                                            serialPortSvgIcon(),
                                            iconMenuSize,
                                            iconMenuSize,
                                            (!isSelect)
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary))
                                    : Icon(
                                        size: iconMenuSize,
                                        Icons.wifi,
                                        color: !isSelect
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                      ),
                              )),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  scale.scaleName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: !isSelect
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  scale.isOnline
                                      ? localizedStrings.gTipOnline
                                      : localizedStrings.gTipOffline,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: isSelect
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : scale.isOnline
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onTertiaryFixedVariant
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )));
          },
        ),
      ),
    );
  }

  Widget buildItemInfo(
      Widget title1, Widget content1, Widget title2, Widget content2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: inputWidth, child: title1),
          SizedBox(width: inputWidth, child: content1)
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: inputWidth, child: title2),
          SizedBox(width: inputWidth, child: content2)
        ])
      ],
    );
  }

//串口秤的明细信息
  Widget showSerialScaleInfo() {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return ListView(
            children: [
              SizedBox(
                height: smallPadding,
              ),
              buildItemInfo(
                  showItemName(context, localizedStrings.gScaleName, false),
                  showScaleNameInputBox(
                      context,
                      scaleNameCtl,
                      '',
                      IconButton(
                        icon: Icon(Icons.edit_outlined), // 清除按钮图标
                        onPressed: () {
                          setState(() {
                            isRename = true;
                          });
                        },
                      ), (value) {
                    setState(() {});
                  }, isRename),
                  showItemName(context, localizedStrings.gModelName, false),
                  showInputBox(context, scaleModelCtl, '', (value) {
                    setState(() {});
                  }, false)),
              SizedBox(
                height: smallPadding,
              ),
              buildItemInfo(
                  showItemName(context, localizedStrings.gScaleSn, false),
                  showInputBox(context, snCtl, '', (value) {
                    setState(() {});
                  }, false),
                  showItemName(context, localizedStrings.gDataBits, false),
                  showDropDownButton(context, '', dataBitCtl, dataBitsList,
                      (value) {
                    setState(() {
                      if (dataBitsList.contains(value)) {
                        dataBitCtl.text = value!;
                      }
                    });
                  })),
              SizedBox(
                height: smallPadding,
              ),
              buildItemInfo(
                  showItemName(context, localizedStrings.gSerialPort, false),
                  showDropDownButton(
                    context,
                    localizedStrings.gTipRefreshPort,
                    comPortCtl,
                    usingComLists,
                    (value) {
                      setState(() {
                        if (value != null && comLists.contains(value)) {
                          comPortCtl.text = value;
                        } else {
                          // 若选择的值不在 comLists 中，清空输入框
                          comPortCtl.clear();
                        }
                        usingComLists = List<String>.from(comLists);
                      });
                    },
                    onTap: () {
                      PublicFunctions.getPortList();
                      if (comLists.isEmpty && comPortCtl.text.isNotEmpty) {
                        comPortCtl.clear();
                      }
                    },
                  ),
                  showItemName(context, localizedStrings.gBaudRate, false),
                  showDropDownButton(context, '', baudRateCtl, baudRateList,
                      (value) {
                    setState(() {
                      if (baudRateList.contains(value)) {
                        baudRateCtl.text = value!;
                      }
                    });
                  })),
              SizedBox(
                height: smallPadding,
              ),
              buildItemInfo(
                  showItemName(context, localizedStrings.gSerialParity, false),
                  showDropDownButton(context, '', protocolCtl, checkBitsList,
                      (value) {
                    setState(() {
                      if (checkBitsList.contains(value)) {
                        protocolCtl.text = value!;
                      }
                    });
                  }),
                  showItemName(context, localizedStrings.gStopBits, false),
                  showDropDownButton(context, '', stopBitCtl, stopBitsList,
                      (value) {
                    setState(() {
                      if (stopBitsList.contains(value)) {
                        stopBitCtl.text = value!;
                      }
                    });
                  })),
              SizedBox(
                height: regularPadding,
              ),
              SizedBox(
                height: regularPadding,
              ),
              isRename ? showRenameConfirmBtn() : showComPortBtn(),
            ],
          );
        }),
      ),
    );
  }

  void modifyComInfo() {
    //串口不能被其他秤使用

    CurrentPort tempPort = CurrentPort();
    tempPort.baud = int.tryParse(baudRateCtl.text);
    tempPort.dataBits = int.tryParse(dataBitCtl.text);
    tempPort.devPath = comPortCtl.text;
    tempPort.parity = 0;
    tempPort.stopBits = 0;

    String infoString = jsonEncode(tempPort);
    myMediaConf.mediaInfoJson = infoString;
    myMediaConf.type = myDevicedata.mediaType;
    myModifyScale.scaleId = selScaleId;
    myModifyScale.scaleModel = scaleModel;
    myModifyScale.mediaConf = myMediaConf;
    PublicFunctions.sendModifyInfo(jsonEncode(myModifyScale));
  }

  Widget showDetailScaleInfo() {
    return Expanded(
        child: SizedBox(
            width: double.infinity,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return ListView(
                children: [
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemName(context, localizedStrings.gScaleName, false),
                      showScaleNameInputBox(
                          context,
                          scaleNameCtl,
                          '',
                          IconButton(
                            icon: Icon(Icons.edit_outlined), // 清除按钮图标
                            onPressed: () {
                              setState(() {
                                isRename = true;
                              });
                            },
                          ), (value) {
                        setState(() {});
                      }, isRename),
                      showItemName(context, localizedStrings.gModelName, false),
                      showInputBox(context, scaleModelCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemName(context, localizedStrings.gScaleSn, false),
                      showInputBox(context, snCtl, '', (value) {
                        setState(() {});
                      }, false),
                      showItemName(context, localizedStrings.gTipPort, false),
                      showInputBox(context, portCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: inputWidth,
                                child: showItemName(context,
                                    localizedStrings.gIpAddress, false)),
                            SizedBox(
                                width: inputWidth,
                                child:
                                    showInputBox(context, ipCtl, '', (value) {
                                  setState(() {});
                                }, false))
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: inputWidth,
                            ),
                            SizedBox(
                              width: inputWidth,
                            )
                          ])
                    ],
                  ),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  isRename ? showRenameConfirmBtn() : buttonRow(),
                ],
              );
            })));
  }

  void checkPortList() {
    if (myComInfoList.msgBody!.isEmpty) {
      comLists = [];
      setState(() {});
    } else {
      comLists = myComInfoList.msgBody!.toList();
    }
  }

  bool validateIpFlag(String value) {
    bool isValid = false;

    setState(() {
      if (value != '') {
        isValid = ipRegex.hasMatch(value);
        isValid = _isValidIpAddress(isValid, value);
      } else {
        isValid = true;
      }
    });
    return isValid;
  }

  Widget showComPortBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        showTextButton(
            context,
            btnHeight,
            localizedStrings.gBtnCloseSerialPort,
            isClosePort || isComSetting
                ? null
                : () {
                    PublicFunctions.closeSerialPort(1);
                    setState(() {
                      isClosePort = true;
                    });
                  },
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.error,
            Theme.of(context).colorScheme.error),
        const SizedBox(
          width: regularPadding,
        ),
        showTextButton(
            context,
            btnHeight,
            localizedStrings.gBtnOpenSerialPort,
            !isClosePort || isComSetting
                ? null
                : () {
                    PublicFunctions.openSerialPort(1);
                    setState(() {
                      isClosePort = false;
                    });
                  },
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.onPrimary),
        const SizedBox(
          width: regularPadding,
        ),
        showTextButton(
            context,
            btnHeight,
            localizedStrings.gBtnConnect,
            isClosePort || isComSetting || comPortCtl.text == ''
                ? null
                : () {
                    for (var scale in myAllScalesList) {
                      if (scale.tMedia == comScaleType) {
                        final serialConfig =
                            scale.mediaConfig as SerialMediaConfig;
                        if (serialConfig.devPath == comPortCtl.text &&
                            scale.scaleId != selScaleId) {
                          showTipInfo(
                              localizedStrings.gTipPortInUsed + scale.scaleName,
                              context);
                          return;
                        }
                      }
                    }
                    setState(() {
                      serialPortConnect = '';
                      isComSetting = true;
                    });
                    modifyComInfo();
                  },
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.onTertiaryFixedVariant,
            Theme.of(context).colorScheme.onPrimary),
        const SizedBox(
          width: regularPadding,
        ),
      ],
    );
  }

  Widget showRenameConfirmBtn() {
    return isRename
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.gBtnConfirm,
                  scaleNameCtl.text.isNotEmpty
                      ? () {
                          modifyScaleName();
                          _isEditing = true;
                        }
                      : null,
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: regularPadding),
              showTextButton(context, btnHeight, localizedStrings.gBtnCancel,
                  () {
                setState(() {
                  isAddScale = false;
                  isRename = false;
                  for (var scale in myAllScalesList) {
                    if (scale.scaleId == selScaleId) {
                      scaleNameCtl.text = scale.scaleName;
                    }
                  }

                  if (isComSetting) {
                    isComSetting = false;
                  }
                });
              },
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  Theme.of(context).colorScheme.onPrimary),
            ],
          )
        : const SizedBox();
  }

  Widget buttonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        showTextButton(
            context,
            btnHeight,
            localizedStrings.gBtnConnect,
            !isAddScale && !isTesting && !isDel && !isComSetting
                ? () {
                    PublicFunctions.checkSerialPort(selScaleId);
                    setState(() {
                      isTesting = true;
                    });
                  }
                : null,
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.onTertiaryFixedVariant,
            Theme.of(context).colorScheme.onPrimary),
      ],
    );
  }

  void addNetScale() {
    myNetInfo.ip = ipCtl.text;
    myNetInfo.port = int.tryParse(portCtl.text)!;
    String netInfoStr = jsonEncode(myNetInfo);
    myMediaConf.mediaInfoJson = netInfoStr;
    myMediaConf.type = 1;
    myAddNetScale.scaleId = 10;
    myAddNetScale.scaleModel = 'TMax';
    myAddNetScale.mediaConf = myMediaConf;
    PublicFunctions.sendAddScale(jsonEncode(myAddNetScale));
  }

  void addComScale() {
    CurrentPort tempPort = CurrentPort();
    tempPort.baud = int.tryParse(baudRateCtl.text);
    tempPort.dataBits = int.tryParse(dataBitCtl.text);
    tempPort.devPath = comPortCtl.text;
    tempPort.parity = 0;
    tempPort.stopBits = 0;
    String infoString = jsonEncode(tempPort);
    AddNetScale addNetScale = AddNetScale(scaleModel: 'TMax');
    myMediaConf.mediaInfoJson = infoString;
    myMediaConf.type = 0;
    addNetScale.scaleId = 10;
    addNetScale.scaleModel = 'TMax';
    addNetScale.mediaConf = myMediaConf;
    PublicFunctions.sendAddScale(jsonEncode(addNetScale));
  }

  bool isValidScaleName(String name) {
    if (scaleNameCtl.text == "ComScale") {
      return false;
    }
    for (NetScaleInfoLocal scaleInfo in myNetScaleList) {
      if (scaleInfo.scaleName == scaleNameCtl.text) {
        return false;
      }
    }
    return true;
  }

  void modifyScaleName() {
    myModifyScaleName.scaleId = selScaleId;
    myModifyScaleName.scaleName = scaleNameCtl.text;
    PublicFunctions.sendModifyScaleName(jsonEncode(myModifyScaleName));
    changeScaleName(myModifyScaleName.scaleId!, myModifyScaleName.scaleName!);
    setState(() {
      isRename = false;
    });
  }

  void changeScaleName(int scaleId, String scaleName) {
    for (var scale in myAllScalesList) {
      if (scale.scaleId == scaleId) {
        scale.scaleName = scaleName;
        break;
      }
    }
  }

  void delScale() {
    DelScaleInfo delScale = DelScaleInfo();
    delScale.scaleId = selScaleId;
    String delStr = jsonEncode(delScale);
    PublicFunctions.sendDelScale(delStr);
    selScaleId = -1;
  }

  void sendToCheckOnline() {
    PublicFunctions.checkSerialPort(1);
    if (myNetScaleList.isEmpty) {
      return;
    }
    for (var i = 0; i < myNetScaleList.length; i++) {
      PublicFunctions.checkSerialPort(myNetScaleList[i].scaleId!);
    }
  }

  void sendStaticIpInfo(String ip, String gateway, String netmask) {
    myScaleCmd.cmdMode = 'set_wifi_static_ip';
    myStaticIpInfo.gateway = gateway;
    myStaticIpInfo.ip = ip;
    myStaticIpInfo.netmask = netmask;
    myScaleCmd.cmdData = jsonEncode(myStaticIpInfo).toString();
    PublicFunctions.sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  //等待进度条
  Widget _buildProcess() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        isDel || isTesting
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

// 新增秤的弹窗
class AddScaleDialog extends StatefulWidget {
  const AddScaleDialog({super.key});
  @override
  AddScaleDialogState createState() => AddScaleDialogState();
}

class AddScaleDialogState extends State<AddScaleDialog> {
  bool isComHovered = false;
  bool isWifiHovered = false;
  bool isBtHovered = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 493,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            Container(
                height: dialogTitleheight,
                padding: const EdgeInsets.only(
                    left: largePadding, right: largePadding),
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: regularPadding,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizedStrings.gTitleAddDevice,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                      onPressed: () {
                        Navigator.pop(context, '');
                      })
                ])),
            // 分割线
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            // 中部
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(26),
                  height: 150,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MouseRegion(
                          onEnter: (_) => setState(() => isComHovered = true),
                          onExit: (_) => setState(() => isComHovered = false),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context, 'com');
                            },
                            child: Container(
                                width: 160,
                                height: 120,
                                alignment: Alignment.center,
                                color: isComHovered
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      getSvgIcon(
                                          serialPortSvgIcon(),
                                          btnHeight,
                                          btnHeight,
                                          isComHovered
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                      SizedBox(
                                        height: regularPadding,
                                      ),
                                      Text(
                                        localizedStrings.gSerialPort,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .apply(
                                                color: isComHovered
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                      )
                                    ])),
                          ),
                        ),
                        SizedBox(
                          width: largePadding,
                        ),
                        MouseRegion(
                          onEnter: (_) => setState(() => isWifiHovered = true),
                          onExit: (_) => setState(() => isWifiHovered = false),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context, 'wifi');
                            },
                            child: Container(
                                width: 140,
                                height: 120,
                                alignment: Alignment.center,
                                color: isWifiHovered
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wifi,
                                        size: btnHeight,
                                        color: isWifiHovered
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      ),
                                      SizedBox(
                                        height: regularPadding,
                                      ),
                                      Text(
                                        'Wi-Fi',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .apply(
                                                color: isWifiHovered
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                      )
                                    ])),
                          ),
                        ),
                        SizedBox(
                          width: largePadding,
                        ),
                      ])),
            ),
            Container(
                height: 140,
                color: Theme.of(context).colorScheme.surface,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(left: 50, right: 50),
                child: SelectableText(
                  localizedStrings.gTipAddDevice,
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                )),
          ],
        ),
      ),
    );
  }
}
