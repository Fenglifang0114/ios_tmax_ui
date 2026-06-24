import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/outline_btn_new.dart';
import 'package:t_max/widget/page_info.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/show_error_dialog.dart';
import '../data/comscaleinfo_data.dart';
import '../data/detail_info.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../data/manager_scale_channel.dart';
import '../data/pak_info_data.dart';
import '../data/scalelist_data.dart';
import '../data/service_status_data.dart';

const String srvUninstalled = "status1"; //服务未安装
const String srvinstalled = "status2"; //服务已安装  服务未启动
const String srvStarted = "status3"; //服务已安装 服务已启动

class RetailReportPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const RetailReportPage(
      {super.key, required this.onNavigate, required this.lastRouteName});

  @override
  RetailReportPageState createState() => RetailReportPageState();
}

class RetailReportPageState extends State<RetailReportPage> {
  final ScrollController _scrollController = ScrollController();
  late final ScrollController _scrollController1 = ScrollController();

  List<TransactionWithExpansion> transactions = [];
  List<NetScaleInfoLocal> scaleNetItems = [];
  NetScaleInfoLocal defNetScaleInfo = NetScaleInfoLocal();
  int selScaleId = -1;
  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus5;
  dynamic eventBus6;

  bool exportFlag = true;
  bool isRefresh = true;
  final int serviceId = 999999999;
  String srvStatus = "";
  String srvStatusMsg = "";

  Timer? _statusTimer;
  Timer? _heartbeatTimer;
  List<int> mySelScaleIdList = [];
  bool isFirstLoad = true;

  // 开始定时器
  void startTimer() {
    if (Platform.isAndroid) return;
    if (_statusTimer == null || !_statusTimer!.isActive) {
      _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        getServiceStatus();
      });
    }
  }

  // 停止定时器
  void stopTimer() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  @override
  void initState() {
    initScaleList();
    srvStatusMsg = (localizedStrings?.gTipWait ?? "gTipWait");
    PublicFunctions.getScaleSrvList(999999999);
    netScaleOpenBill();
    startHeartbeatTimer();
    // PublicFunctions.getDetailList();
    isRefresh = true;
    startTimer();
    if (Platform.isAndroid) {
      srvStatus = srvStarted;
      srvStatusMsg = (localizedStrings?.gTipServiceStarted ?? "gTipServiceStarted");
      if (isFirstLoad) {
        isFirstLoad = false;
        PublicFunctions.getDetailList();
      }
    }
    eventBus1 = eventBus.on<EventRespDetailInfo>().listen((event) {
      if (mounted) {
        isRefresh = true;
        setState(() {
          try {
            String detailStr = event.obj;
            myDetailRevPak = RevPakInfo(msgBody: StringBuffer());
            final detailInfoRev = detailInfoRevFromJson(detailStr);
            transactions = detailInfoRev.map((detail) {
              return TransactionWithExpansion(
                total: detail.total,
                details: detail.details,
              );
            }).toList();
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        });
      }
    });
    eventBus2 = eventBus.on<EventRevDetailTail>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
          if (Platform.isAndroid) {
            PublicFunctions.getDetailList();
          } else {
            PublicFunctions.getDetailListSrv1();
          }
          isRefresh = true;
        }
      }
    });
    eventBus3 = eventBus.on<EventRespDetailAdd>().listen((event) {
      if (mounted) {
        if (Platform.isAndroid) {
          PublicFunctions.getDetailList();
        } else {
          PublicFunctions.getNewDetailFormSrv1();
        }
        isRefresh = true;
      }
    });

    eventBus4 = eventBus.on<EventRespScaleSrvList>().listen((event) {
      if (mounted) {
        String dataString = event.obj;
        try {
          mySrvScaleList = srvScaleListFromJson(dataString);
          if (mySrvScaleList.isNotEmpty) {
            for (int i = 0; i < mySrvScaleList.length; i++) {
              if (!mySelScaleIdList.contains(mySrvScaleList[i].scaleId)) {
                mySelScaleIdList.add(mySrvScaleList[i].scaleId);
              }
            }
          }
          setState(() {});
        } catch (e) {
          return;
        }
      }
    });

    eventBus4 = eventBus.on<EventRespScaleOnline>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });

    eventBus5 = eventBus.on<EventRespDoSrvAction>().listen((event) {
      if (mounted) {
        String msgStr = event.obj;

        const String srvUninstalled = "status1"; //服务未安装
        const String srvinstalled = "status2"; //服务已安装  服务未启动
        const String srvStarted = "status3"; //服务已安装 服务已启

        if (msgStr.contains("Status:")) {
          final splitted = msgStr.split("Status:");
          if (splitted.isNotEmpty) {
            setState(() {
              srvStatus = splitted[1];
              switch (srvStatus) {
                case srvUninstalled:
                  srvStatusMsg = (localizedStrings?.gTipServiceUninstalled ?? "gTipServiceUninstalled");

                  break;
                case srvinstalled:
                  srvStatusMsg = (localizedStrings?.gTipServiceStoped ?? "gTipServiceStoped");

                  break;
                case srvStarted:
                  srvStatusMsg = (localizedStrings?.gTipServiceStarted ?? "gTipServiceStarted");
                  if (isFirstLoad) {
                    isFirstLoad = false;
                    if (Platform.isAndroid) {
                      PublicFunctions.getDetailList();
                    } else {
                      PublicFunctions.getDetailListSrv1();
                    }
                  }

                  break;
              }
            });
          }
        } else {
          switch (msgStr) {
            case srvUninstalled:
              msgStr = (localizedStrings?.gTipServiceUninstalled ?? "gTipServiceUninstalled");

              break;
            case srvinstalled:
              msgStr = (localizedStrings?.gTipServiceStoped ?? "gTipServiceStoped");

              break;
            case srvStarted:
              msgStr = (localizedStrings?.gTipServiceStarted ?? "gTipServiceStarted");

              break;
          }
          showErrorDialog(context, msgStr);
        }
      }
    });

    eventBus6 = eventBus.on<EventRespNewDetailInfo>().listen((event) {
      if (mounted) {
        if (Platform.isAndroid) return; // Android directly reads from DB, ignore raw event
        isRefresh = true;
        setState(() {
          try {
            String detailStr = event.obj;
            myDetailRevPak = RevPakInfo(msgBody: StringBuffer());
            final detailInfoRev = detailInfoRevFromJson(detailStr);
            for (int i = 0; i < detailInfoRev.length; i++) {
              var res = checkDetailExist(detailInfoRev[i].total.recId);
              if (!res) {
                var newDetailInfo = TransactionWithExpansion(
                  total: detailInfoRev[i].total,
                  details: detailInfoRev[i].details,
                );
                transactions.add(newDetailInfo);
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        });
      }
    });

    super.initState();
  }

  bool checkDetailExist(int recId) {
    bool res = false;
    if (transactions.isEmpty) {
      return res;
    }

    for (int i = 0; i < transactions.length; i++) {
      if (transactions[i].total.recId == recId) {
        return true;
      }
    }
    return res;
  }

  void netScaleOpenBill() {
    if (myAllScalesList.isNotEmpty) {
      for (int i = 0; i < myAllScalesList.length; i++) {
        // WiFi and Bluetooth
        if (myAllScalesList[i].tMedia == 1 || myAllScalesList[i].tMedia == 2) {
          PublicFunctions.openBillSend(myAllScalesList[i].scaleId);
        }
      }
    }
  }

  void startHeartbeatTimer() {
    if (_heartbeatTimer == null || !_heartbeatTimer!.isActive) {
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (myAllScalesList.isNotEmpty) {
          for (int i = 0; i < myAllScalesList.length; i++) {
            if (myAllScalesList[i].tMedia == 1 || myAllScalesList[i].tMedia == 2) {
              PublicFunctions.sendCalHeartBeat(myAllScalesList[i].scaleId);
            }
          }
        }
      });
    }
  }

  void stopHeartbeatTimer() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void initScaleList() {
    scaleNetItems = myNetScaleList;
    selScaleId = myDefScaleInfo.defScaleId!;
    if (myNetScaleList.isNotEmpty) {
      defNetScaleInfo = NetScaleListMgr.findScaleInfo(
          myNetScaleList, myDefScaleInfo.defScaleId!);
    }
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus2.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus5.cancel();
    eventBus6.cancel();
    _statusTimer?.cancel();
    stopHeartbeatTimer();
    _scrollController.dispose();
    _scrollController1.dispose();
    super.dispose();
  }

  Widget customTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall!.apply(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget showTitleName(String title) {
    return SizedBox(
      height: 42,
      child: Row(children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: customTitle(title),
          ),
        ),
      ]),
    );
  }

  TextStyle getTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        );
  }

  TextStyle getTitleTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= colorScheme.onSurface;
    return Theme.of(context).textTheme.bodyMedium!.apply(
          color: color,
        );
  }

  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  Widget myHeadInfo(dynamic context, String pageTitle, String helpInfo,
      {bool showHelp = true}) {
    return Container(
        height: pageTopTitleHeight,
        color: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: subTitle(context, pageTitle),
                ),
                Row(
                  children: [
                    SizedBox(
                      child: Text(
                        (localizedStrings?.gTipServiceStatus ?? "gTipServiceStatus"),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      child: Text(srvStatusMsg,
                          style: getTextStyle(
                              color: srvStatus.contains(srvStarted)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error),
                          overflow: TextOverflow.ellipsis),
                    )
                  ],
                ),
                if (showHelp)
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    PageInfoButton(helpInfo: helpInfo, onRefresh: () {}),
                    const SizedBox(
                      width: largePadding,
                    ),
                  ])
              ],
            ),
          ),
        ]));
  }

  Widget subTitle(
    dynamic context,
    String pageTitle,
  ) {
    return Row(
      children: [
        SizedBox(
          width: largePadding,
        ),
        SizedBox(
          child: IconButton(
              onPressed: () {
                Future.delayed(Duration.zero, () {
                  widget.onNavigate(widget.lastRouteName);
                });
              },
              icon: getSvgIcon(returnSvgIcon(), 28, 28,
                  Theme.of(context).colorScheme.primary)),
        ),
        SizedBox(
          width: regularPadding,
        ),
        Expanded(
          child: Text(
            pageTitle,
            style: Theme.of(context).textTheme.labelMedium!.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxheight = MediaQuery.of(context).size.height;

    transactions.sort((a, b) => b.total.createdAt.compareTo(a.total.createdAt));

    return Scaffold(
      body: Container(
          width: maxWidth,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                myHeadInfo(context, (localizedStrings?.menuRetailReport ?? "menuRetailReport"),
                    (localizedStrings?.gTipRetailDetailPageHelp ?? "gTipRetailDetailPageHelp")),
                Container(
                  height: regularPadding,
                  color: colorScheme.surfaceDim,
                ),
                showContent(maxheight),
              ])),
    );
  }

  Widget showContent(double maxheight) {
    return Expanded(
      child: SizedBox(
          child: Row(
        children: [
          showScaleList(),
          Container(
            width: regularPadding,
            color: colorScheme.surfaceDim,
          ),
          Expanded(
            child: Column(
              children: [
                showBtnList(),
                Expanded(
                  child: showDataList(),
                )
              ],
            ),
          )
        ],
      )),
    );
  }

  Widget showBtnList() {
    return SizedBox(
      height: pageTopTitleHeight,
      child: Row(
        children: [
          if (!Platform.isAndroid) showInstallRow(),
          Spacer(),
          SizedBox(
            child: Row(
              children: [
                showTextButton(context, 40, (localizedStrings?.rRefreshListBtn ?? "rRefreshListBtn"),
                    () {
                  if (Platform.isAndroid) {
                    PublicFunctions.getDetailList();
                  } else {
                    PublicFunctions.getDetailListSrv1();
                  }
                }, colorScheme.onPrimary, colorScheme.primary,
                    colorScheme.onPrimary),
                SizedBox(
                  width: largePadding,
                ),
                showTextButton(
                    context,
                    40,
                    (localizedStrings?.gBtnExport ?? "gBtnExport"),
                    exportFlag ? exportToCsv : null,
                    colorScheme.onPrimary,
                    colorScheme.primary,
                    colorScheme.onPrimary)
              ],
            ),
          ),
          SizedBox(
            width: largePadding,
          ),
        ],
      ),
    );
  }

  Widget showScaleList() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceTint,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: regularPadding,
            ),
            Expanded(
              child: NewMutiScaleListWifiWidget(
                listWidth: appScaleListWidth, // 列表宽度
                selScaleList: mySelScaleIdList,
                clickScale: (scale) {
                  setState(() {
                    addOrRemoveSelScale(scale.scaleId);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showDataList() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth;
        double maxHeight = constraints.maxHeight;
        return Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // 垂直滚动
                controller: _scrollController1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: maxWidth < 1000 ? 1000 : maxWidth,
                      height: maxHeight - 30,
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              buildCartTitle(transactions[index]),
                              if (transactions[index].isExpanded)
                                buildCardDetail(transactions[index]),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget showInstallRow() {
    return Row(
      children: [
        SizedBox(
          width: smallPadding,
        ),
        CustomGeneralButton(
          text: (localizedStrings?.gTipInstallService ?? "gTipInstallService"),
          maxWidth: 200,
          onPressed: () {
            _performActionForOption('Install');
          },
        ),
        SizedBox(
          width: smallPadding,
        ),
        CustomGeneralButton(
          text: (localizedStrings?.gTipStartService ?? "gTipStartService"),
          maxWidth: 200,
          onPressed: () {
            _performActionForOption('Start');
          },
        ),
        SizedBox(
          width: smallPadding,
        ),
        CustomGeneralButton(
          text: (localizedStrings?.gTipStopService ?? "gTipStopService"),
          maxWidth: 200,
          onPressed: () {
            _performActionForOption('Stop');
          },
        ),
        SizedBox(
          width: smallPadding,
        ),
        CustomGeneralButton(
          text: (localizedStrings?.gTipUninstallService ?? "gTipUninstallService"),
          maxWidth: 200,
          onPressed: () {
            _performActionForOption('Uninstall');
          },
        ),
      ],
    );
  }

  void addOrRemoveSelScale(int scaleId) {
    if (mySelScaleIdList.contains(scaleId)) {
      mySelScaleIdList.remove(scaleId);
    } else {
      mySelScaleIdList.add(scaleId);
    }
    setScaleRelStatus(scaleId, getStatus(scaleId));
  }

  void _performActionForOption(String option) {
    switch (option) {
      case 'Install':
        if (srvStatus.contains(srvUninstalled)) {
          ServiceAction mySrvAct =
              ServiceAction(action: "Install", serviceId: serviceId);

          PublicFunctions.sendServiceAction(serviceActionToJson(mySrvAct));
          srvStatus = "";
          srvStatusMsg = (localizedStrings?.gTipWait ?? "gTipWait");
        } else {
          showErrorDialog(context, srvStatusMsg);
        }

        break;
      case 'Start':
        if (srvStatus.contains(srvinstalled)) {
          ServiceAction mySrvAct =
              ServiceAction(action: "Start", serviceId: serviceId);
          PublicFunctions.sendServiceAction(serviceActionToJson(mySrvAct));
          srvStatus = "";
          srvStatusMsg = (localizedStrings?.gTipWait ?? "gTipWait");
        } else {
          showErrorDialog(context, srvStatusMsg);
        }
        break;
      case 'Stop':
        if (srvStatus.contains(srvStarted)) {
          ServiceAction mySrvAct =
              ServiceAction(action: "Stop", serviceId: serviceId);
          PublicFunctions.sendServiceAction(serviceActionToJson(mySrvAct));
          srvStatus = "";
          srvStatusMsg = (localizedStrings?.gTipWait ?? "gTipWait");
        } else {
          showErrorDialog(context, srvStatusMsg);
        }
        break;
      case 'Uninstall':
        if (srvStatus.contains(srvinstalled)) {
          ServiceAction mySrvAct =
              ServiceAction(action: "Uninstall", serviceId: serviceId);
          PublicFunctions.sendServiceAction(serviceActionToJson(mySrvAct));
          srvStatus = "";

          srvStatusMsg = (localizedStrings?.gTipWait ?? "gTipWait");
        } else {
          showErrorDialog(context, srvStatusMsg);
        }

        break;
    }
  }

  void getServiceStatus() {
    ServiceAction mySrvAct =
        ServiceAction(action: "Status", serviceId: serviceId);
    PublicFunctions.sendServiceAction(serviceActionToJson(mySrvAct));
  }

  void setScaleRelStatus(int scaleId, bool status) {
    for (int i = 0; i < mySrvScaleList.length; i++) {
      if (mySrvScaleList[i].scaleId == scaleId &&
          mySrvScaleList[i].srvId == serviceId) {
        mySrvScaleList[i].isUsed = !status;
      }
    }
    SrvScaleInfo srvInfo =
        SrvScaleInfo(scaleId: scaleId, srvId: serviceId, isUsed: !status);
    String dataStr = json.encode(srvInfo);
    PublicFunctions.setScaleSrvStatus(dataStr);
  }

  bool getStatus(int scaleId) {
    if (mySrvScaleList.isEmpty) {
      return false;
    }
    for (int i = 0; i < mySrvScaleList.length; i++) {
      if (mySrvScaleList[i].scaleId == scaleId &&
          mySrvScaleList[i].srvId == serviceId) {
        return mySrvScaleList[i].isUsed;
      }
    }
    return false;
  }

  Widget buildCardDetail(TransactionWithExpansion tran) {
    return Column(
      // children: tran.details.map((detail) {
      children: tran.details
          .where((detail) => detail.pluReturnFlag != "Cancel")
          .map((detail) {
        return Card(
          color: colorScheme.surface,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: ListTile(
            title: Row(
              children: [
                Text(
                  'PLU：${detail.pluNum}',
                  style: getTextStyle(),
                ),
                const Text('        '),
                Text(
                  'Name：${detail.pluName}',
                  style: getTextStyle(),
                ),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildDetailText('Wgt：${detail.pluTotalWeight.toString()}'),
                buildDetailText('PCS：${detail.pluQuantity.toString()}'),
                buildDetailText('PLU Unit：${detail.pluUnit.toString()}'),
                buildDetailText('Tare：${detail.pluTare.toString()}'),
                buildDetailText('Unit Price：${detail.pluUnitPrice.toString()}'),
                buildDetailText('Tax Type：${detail.pluTaxType.toString()}'),
                buildDetailText('Tax Price：${detail.pluTaxPrice.toString()}'),
                buildDetailText(
                    'Return Flag：${detail.pluReturnFlag.toString()}'),
                buildDetailText(
                    'Change Type：${detail.pluChangeType.toString()}'),
                buildDetailText(
                    'Total Price：${detail.pluTotalPrice.toString()}'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildDetailText(String detail) {
    return Expanded(
      flex: 1,
      child: Text(
        detail,
        style: getTextStyle(color: colorScheme.onSurface),
      ),
    );
  }

  Widget buildCartTitle(TransactionWithExpansion tran) {
    return Card(
      elevation: 1, //阴影宽度
      color: colorScheme.surfaceDim,
      shadowColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: ListTile(
        title: Row(
          children: [
            Text(
              '${tran.total.scaleModel}/${tran.total.scaleSn}',
              style: getTitleTextStyle(color: colorScheme.primary),
            ),
            const Text('        '),
            Text(
              'ID：${tran.total.settleAccountTimes}',
              style: getTitleTextStyle(color: colorScheme.primary),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // buildDetailText(
            //     'Time：${DateFormat('yyyy-MM-dd HH:mm:ss').format(tran.total.createdAt)}'),
            buildDetailText(
                'Time：${convertDateTime(tran.total.createdAt.toString())}'),
            buildDetailText('Total Amount：${tran.total.totalPrice.toString()}'),
            buildDetailText('Pay Amount：${tran.total.payPrice.toString()}'),
            buildDetailText('ACC Count：${tran.total.totalCount.toString()}'),
            buildDetailText('Tax Type：${tran.total.taxKind.toString()}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(tran.isExpanded ? Icons.expand_less : Icons.expand_more),
          onPressed: () {
            setState(() {
              tran.isExpanded = !tran.isExpanded;
            });
          },
        ),
      ),
    );
  }

  String convertDateTime(String timestr) {
    DateTime originalTime = DateTime.parse(timestr);

    DateTime localTime = originalTime.toLocal();
    var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String formattedTime = formatter.format(localTime);
    return formattedTime;
  }

  Widget buildText(String text) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: const TextStyle(overflow: TextOverflow.ellipsis),
    );
  }

  Future<void> exportToCsv() async {
    exportFlag = false;
    List<String> header = [
      'Model Name',
      'Sn',
      'ID',
      'Time',
      'Tax Type',
      'Plu Count',
      'Total Amount',
      'Pay Amount',
      'Index',
      'PLU Number',
      'PLU Name',
      'Weight',
      'Quantity',
      'Unit',
      'Unit Price',
      'Tare',
      'Tax Type',
      'Tax Price',
      'Return Flag',
      'Change Type',
      'Total Amount',
    ];

    List<List<String>> data = [];

    for (var transaction in transactions) {
      List<String> row = [
        transaction.total.scaleModel.toString(),
        transaction.total.scaleSn.toString(),
        transaction.total.settleAccountTimes.toString(),
        convertDateTime(transaction.total.createdAt.toString()),
        // DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.total.createdAt),
        transaction.total.taxKind.toString(),
        transaction.total.totalCount.toString(),
        transaction.total.totalPrice.toString(),
        transaction.total.payPrice.toString(),
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ];
      data.add(row);

      for (var detail in transaction.details) {
        if (detail.pluReturnFlag != "Cancel") {
          row = [
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            detail.pluIndex,
            detail.pluNum,
            detail.pluName,
            detail.pluTotalWeight,
            detail.pluQuantity,
            detail.pluUnit,
            detail.pluUnitPrice,
            detail.pluTare,
            detail.pluTaxType,
            detail.pluTaxPrice,
            detail.pluReturnFlag,
            detail.pluChangeType,
            detail.pluTotalPrice,
          ];
          data.add(row);
        }
      }
    }

    data.insert(0, header);

    String? outputFile;
    
    if (Platform.isAndroid) {
      // 检查权限
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      // Android: Prompt user to select directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Output Folder',
      );

      if (selectedDirectory != null) {
        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        outputFile = "$selectedDirectory/report_$timestamp.csv";
      } else {
        // User canceled directory selection
        exportFlag = true;
        return;
      }
    } else {
      // Desktop: Use FilePicker
      var directory = Directory.current.path;
      outputFile = (await FilePicker.platform.saveFile(
        initialDirectory: directory,
        dialogTitle: 'Output file:',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        fileName: 'report.csv',
      ));
    }

    if (outputFile != null) {
      if (!outputFile.contains(".csv")) {
        outputFile = "$outputFile.csv";
      }
      final filePath = outputFile;
      File file = File(filePath);
      try {
        await file.writeAsString(
          List.generate(data.length, (index) => data[index].join(','))
              .join('\n'),
        );
        if (mounted && context.mounted) {
          showErrorDialog(context, 'OK    ${file.path}');
        }
      } catch (e) {
        if (mounted && context.mounted) {
          showErrorDialog(context, e.toString());
        }
      }
    }
    exportFlag = true;
  }
}

class TransactionWithExpansion extends DetailInfoRev {
  bool isExpanded;
  TransactionWithExpansion({
    required super.total,
    required super.details,
    this.isExpanded = false,
  });
}
