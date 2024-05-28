import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/eventbus/eventbus.dart';

import '../data/get_theme_color.dart';
import '../data/setting_version_info.dart';
import '../generated/l10n.dart';

import '../data/comscaleinfo_data.dart';
import '../data/currentport_data.dart';
import '../data/device_data.dart';
import '../functions/methods.dart';

import '../widget/box_gradient.dart';
import '../widget/theme_color.dart';
import '../widget/version.dart';

class TrialPage extends StatefulWidget {
  const TrialPage({Key? key}) : super(key: key);

  @override
  State<TrialPage> createState() => TrialPageState();
}

class TrialPageState extends State<TrialPage> {
  bool ischangepassword = true;
  bool isPass = false;
  bool liceseKey = false;
  String pId = '';
  String dueDate = '';
  late Timer timer;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  TextEditingController pidController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  String systemId = '';
  String errMessage = '';

  @override
  void initState() {
    super.initState();
    pidController.text = systemId;
    licenseController.text = '';

    _eventbus1 = eventBus.on<EventLicenseData>().listen((event) {
      if (mounted) {
        setState(() {
          myLicenseData = event.obj;
          if (myLicenseData.data.isNotEmpty) {
            List<String> strList = myLicenseData.data.split(',');
            pId = strList[1]; // id
            dueDate = strList[2];
            if (strList[0] == 'true') {
              isPass = true;
            }
            pidController.text = systemId + pId;
            myLicenseInfo.isValid = isPass;
            myLicenseInfo.pId = pId;
            myLicenseInfo.liceseDate = dueDate;
          }
          if (isPass) {
            PublicFunctions.getScaleList();
            PublicFunctions.getUIConfNormal();
            PublicFunctions.getUIConfCheck();
            PublicFunctions.getUIConfTakeIn();
            PublicFunctions.getUIConfTakeOut();
            PublicFunctions.getOneEepromInfo("wifi_or_bt");
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return mySystemVersionInfo.getHomePage(mySystemVersion);
              // return const HomePage();
              // return const IndustryHomePage();
            }));
          }
        });
      }
    });
    _eventbus2 = eventBus.on<EventComScaleList>().listen((event) {
      if (mounted) {
        setState(() {
          myComScaleList = event.obj;
          if (myComScaleList.comScaleList.isNotEmpty) {
            myDevicedata.name = myComScaleList.comScaleList[0].scaleModel;
            myDevicedata.type = 'icons.usb';
            myDevicedata.scaleID =
                myComScaleList.comScaleList[0].scaleId.toString();
            myCurrentPort.baud = myComScaleList.comScaleList[0].baudRate;
            myCurrentPort.dataBits = myComScaleList.comScaleList[0].dataBits;
            myCurrentPort.devPath = myComScaleList.comScaleList[0].portName;
            myCurrentPort.parity = myComScaleList.comScaleList[0].parity;
            myCurrentPort.stopBits = myComScaleList.comScaleList[0].stopBits;
            myDevicedata.mediaType = myComScaleList.comScaleList[0].tMedia;
            myDevicedata.scaleSn = myComScaleList.comScaleList[0].scaleSn;
          }
        });
      }
    });
    _eventbus3 = eventBus.on<EventCheckLicenseKey>().listen((event) {
      if (mounted) {
        setState(() {
          myLicenseData = event.obj;
          if (myLicenseData.data.isNotEmpty) {
            List<String> strList = myLicenseData.data.split(',');
            pId = strList[1]; // id
            dueDate = strList[2];
            if (strList[0] == 'true') {
              liceseKey = true;
            }
            pidController.text = systemId + pId;
          }
          if (liceseKey) {
            if (myLicenseInfo.isValid) {
              if (isLongerValidityPeriod(myLicenseInfo.liceseDate, dueDate)) {
                //要更新最新的日期的license
                updateLicenseInfo();
              }
            } else {
              updateLicenseInfo();
            }
          } else {
            errMessage = 'Invalid license';
          }
        });
      }
    });

    //初始化
    // WebsocketManager.init();
  }

  dynamic localizedStrings;
  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    pidController.dispose();
    licenseController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    systemId = localizedStrings.system_id;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeColor(colorTheme),
        home: Scaffold(
            // AppBar：相当于iOS 的导航栏
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: AppBar(
                  title: versionInfo(Theme.of(context).colorScheme.onPrimary),
                  //设置状态栏颜色渐变
                  flexibleSpace: Container(
                      decoration:
                          BoxDecoration(gradient: boxGradient(context))),
                )),
            body: ListView(
              children: [
                Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                    SizedBox(
                      height: _height,
                      width: _width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              width: 500,
                              child: Card(
                                shadowColor:
                                    Theme.of(context).colorScheme.background,
                                elevation: 40,
                                margin: const EdgeInsets.all(10),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      localizedStrings.welcome,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: pidController,
                                      readOnly: true,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: 400,
                                      child: TextField(
                                        controller: licenseController,
                                        textAlign: TextAlign.start,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        maxLines: 2,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(74),
                                          FilteringTextInputFormatter.allow(RegExp(
                                              r'^[a-zA-Z0-9\-]+$')), // 允许输入数字和点
                                        ],
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            errMessage = '';
                                            isValidLicense();
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                        onPressed: (isValidLicense() &&
                                                !liceseKey)
                                            ? () {
                                                PublicFunctions.checkLicenseKey(
                                                    licenseController.text);
                                              }
                                            : null,
                                        child: Text(
                                          localizedStrings.button_add_license,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                    const SizedBox(height: 10),
                                    !liceseKey && errMessage.isNotEmpty
                                        ? SizedBox(
                                            height: 40,
                                            child: Text(errMessage,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error)),
                                          )
                                        : const Text(''),
                                    Text(
                                        (liceseKey)
                                            ? localizedStrings.passed_message
                                            : localizedStrings
                                                .passed_fail_message,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: (liceseKey)
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error)),
                                    Text(
                                        (dueDate.isEmpty)
                                            ? ''
                                            : localizedStrings.expiration_date +
                                                dueDate,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: (liceseKey)
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .outline
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error)),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                //跳转页面
                                                PublicFunctions.getScaleList();
                                                PublicFunctions
                                                    .getUIConfNormal();
                                                PublicFunctions
                                                    .getUIConfCheck();
                                                PublicFunctions
                                                    .getUIConfTakeIn();
                                                PublicFunctions
                                                    .getUIConfTakeOut();
                                                PublicFunctions
                                                    .getOneEepromInfo(
                                                        "wifi_or_bt");
                                                Navigator.pushReplacement(
                                                    context, MaterialPageRoute(
                                                        builder: (context) {
                                                  // return const HomePage();
                                                  return mySystemVersionInfo
                                                      .getHomePage(
                                                          mySystemVersion);
                                                }));
                                              });
                                            },
                                            child: Text(
                                              liceseKey
                                                  ? localizedStrings
                                                      .button_start
                                                  : localizedStrings
                                                      .button_trial,
                                              // : localizedStrings
                                              //     .button_exit
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              //跳转页面
                                              exit(0);
                                            });
                                          },
                                          child: Text(
                                            localizedStrings.button_exit,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      localizedStrings.text_email,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                  width: 250,
                                  child:
                                      Image.asset('assets/images/company.png')),
                              const SizedBox(width: 100)
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            )));
  }

  bool isValidLicense() {
    bool res = false;
    String dataStr = licenseController.text;
    if (dataStr.isNotEmpty && utf8.encode(dataStr).length == 74) {
      res = true;
    }
    return res;
  }

  void updateLicenseInfo() {
    myLicenseInfo.isValid = liceseKey;
    myLicenseInfo.pId = pId;
    myLicenseInfo.liceseDate = dueDate;
    PublicFunctions.updateLicense(licenseController.text);
  }

//验证新日期是否可用，true 可用，直接更新，false 询问是否更新
  bool isLongerValidityPeriod(String oldLicenseDate, String newLicenseDate) {
    bool res = false;
    DateTime dateTimeOld = DateTime.parse(oldLicenseDate);
    DateTime dateTimeNew = DateTime.parse(newLicenseDate);

    if (dateTimeOld.isBefore(dateTimeNew)) {
      res = true;
    }
    return res;
  }
}
