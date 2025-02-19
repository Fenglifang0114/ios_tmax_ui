import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/custom_button.dart';
import '../data/comscaleinfo_data.dart';
import '../data/detail_info.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../data/manager_scale_channel.dart';
import '../data/pak_info_data.dart';
import '../data/scalelist_data.dart';
import '../data/service_status_data.dart';
import '../widget/page_head.dart';

const String srvUninstalled = "status1"; //服务未安装
const String srvinstalled = "status2"; //服务已安装  服务未启动
const String srvStarted = "status3"; //服务已安装 服务已启动

class TransactionReportPage extends StatefulWidget {
  const TransactionReportPage({super.key});

  @override
  TransactionReportPageState createState() => TransactionReportPageState();
}

class TransactionReportPageState extends State<TransactionReportPage> {
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

  // 开始定时器
  void startTimer() {
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

    srvStatusMsg = localizedStrings.gTipWait;

    PublicFunctions.getScaleSrvList(999999999);
    netScaleOpenBill();
    // PublicFunctions.getDetailList();
    isRefresh = true;
    startTimer();
    eventBus1 = eventBus.on<EventRespDetailInfo>().listen((event) {
      if (mounted) {
        isRefresh = true;
        setState(() {
          try {
            String detailStr = myDetailRevPak.msgBody.toString();
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
        // if (myRespDataFromScale.msgBody.contains('ok')) {
        //   PublicFunctions.getDetailList();
        //   isRefresh = true;
        // }
      }
    });
    eventBus3 = eventBus.on<EventRespDetailAdd>().listen((event) {
      if (mounted) {
        PublicFunctions.getNewDetailFormSrv1();
        isRefresh = true;
      }
    });

    eventBus4 = eventBus.on<EventRespScaleSrvList>().listen((event) {
      if (mounted) {
        String dataString = event.obj;
        try {
          mySrvScaleList = srvScaleListFromJson(dataString);
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
                  srvStatusMsg = localizedStrings.gTipServiceUninstalled;

                  break;
                case srvinstalled:
                  srvStatusMsg = localizedStrings.gTipServiceStoped;

                  break;
                case srvStarted:
                  srvStatusMsg = localizedStrings.gTipServiceStarted;

                  break;
              }
            });
          }
        } else {
          switch (msgStr) {
            case srvUninstalled:
              msgStr = localizedStrings.gTipServiceUninstalled;

              break;
            case srvinstalled:
              msgStr = localizedStrings.gTipServiceStoped;

              break;
            case srvStarted:
              msgStr = localizedStrings.gTipServiceStarted;

              break;
          }
          _showErrorDialog(context, msgStr);
        }
      }
    });

    eventBus6 = eventBus.on<EventRespNewDetailInfo>().listen((event) {
      if (mounted) {
        isRefresh = true;
        setState(() {
          try {
            String detailStr = myDetailRevPak.msgBody.toString();
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
    if (myNetScaleList.isNotEmpty) {
      for (int i = 0; i < myNetScaleList.length; i++) {
        PublicFunctions.openBillSend(myNetScaleList[i].scaleId!);
      }
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxheight = MediaQuery.of(context).size.height;

    transactions.sort((a, b) => b.total.createdAt.compareTo(a.total.createdAt));

    return Scaffold(
      appBar: AppBar(
          title: Container(
            child: pageHeadDesign(context, localizedStrings.rDetailRptTitle, [],
                localizedStrings.gTipRetailDetailPageHelp),
          ),
          leading: IconTheme(
              data: IconThemeData(
                  color: Theme.of(context).colorScheme.primary // 设置抽屉图标颜色为红色
                  ),
              child: Builder(builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }))),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        localizedStrings.gTipServiceStatus,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 200,
                      child: Text(srvStatusMsg,
                          style: TextStyle(
                              color: srvStatus.contains(srvStarted)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error),
                          overflow: TextOverflow.ellipsis),
                    )
                  ],
                ),
                CustomOutlinedButton(
                    btnWidth: 100,
                    btnHeight: 50,
                    icon: Icons.refresh,
                    text: localizedStrings.rRefreshListBtn,
                    onPressed: () {
                      PublicFunctions.getDetailListSrv1();
                    }),
                const SizedBox(
                  width: 20,
                ),
                CustomOutlinedButton(
                    btnWidth: 100,
                    btnHeight: 50,
                    icon: Icons.save,
                    text: localizedStrings.gBtnExport,
                    onPressed: exportFlag ? exportToCsv : null),
                const SizedBox(
                  width: 20,
                ),
                PopupMenuButton<String>(
                    onSelected: _performActionForOption,
                    tooltip: '',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'Install',
                          child: Text(
                            localizedStrings.gTipInstallService,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Start',
                          child: Text(
                            localizedStrings.gTipStartService,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Stop',
                          child: Text(
                            localizedStrings.gTipStopService,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Uninstall',
                          child: Text(
                            localizedStrings.gTipUninstallService,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ];
                    },
                    child: Container(
                      width: 120,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          localizedStrings.gTipService,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ))
              ],
            ),
            SizedBox(
              width: maxWidth - 20,
              height: maxheight - 110,
              child: Scrollbar(
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
                            height: maxheight - 110,
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
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(child: myDrawer() // showNetScaleList(),
          ),
    );
  }

  void _performActionForOption(String option) {
    switch (option) {
      case 'Install':
        if (srvStatus.contains(srvUninstalled)) {
          ServiceAction mySrvAct =
              ServiceAction(action: "Install", serviceId: serviceId);

          PublicFunctions.sendServiceAction(serviceActionToJson(mySrvAct));
          srvStatus = "";
          srvStatusMsg = localizedStrings.gTipWait;
        } else {
          _showErrorDialog(context, srvStatusMsg);
        }

        break;
      case 'Start':
        if (srvStatus.contains(srvinstalled)) {
          ServiceAction mySrvAct =
              ServiceAction(action: "Start", serviceId: serviceId);
          PublicFunctions.sendServiceAction(serviceActionToJson(mySrvAct));
          srvStatus = "";
          srvStatusMsg = localizedStrings.gTipWait;
        } else {
          _showErrorDialog(context, srvStatusMsg);
        }
        break;
      case 'Stop':
        if (srvStatus.contains(srvStarted)) {
          ServiceAction mySrvAct =
              ServiceAction(action: "Stop", serviceId: serviceId);
          PublicFunctions.sendServiceAction(serviceActionToJson(mySrvAct));
          srvStatus = "";
          srvStatusMsg = localizedStrings.gTipWait;
        } else {
          _showErrorDialog(context, srvStatusMsg);
        }
        break;
      case 'Uninstall':
        if (srvStatus.contains(srvinstalled)) {
          ServiceAction mySrvAct =
              ServiceAction(action: "Uninstall", serviceId: serviceId);
          PublicFunctions.sendServiceAction(serviceActionToJson(mySrvAct));
          srvStatus = "";

          srvStatusMsg = localizedStrings.gTipWait;
        } else {
          _showErrorDialog(context, srvStatusMsg);
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
    setState(() {});
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

  Widget myDrawer() {
    return Column(
      children: [
        SizedBox(
          height: 50, // 设置抽屉头部高度为100像素
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            child: Center(
              child: Text(
                localizedStrings.gTipScaleList,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        showNetScaleList()
        // 抽屉其他内容
      ],
    );
  }

  Widget showNetScaleList() {
    return Expanded(
      child: ListView.builder(
        itemCount: scaleNetItems.length,
        itemBuilder: (context, index) {
          return SizedBox(
            child: Column(
              children: [
                ListTile(
                  selected: selScaleId == scaleNetItems[index].scaleId,
                  dense: true,
                  title: Tooltip(
                    richMessage: TextSpan(
                      text: '${scaleNetItems[index].ip!}\r\n\r\n',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      children: <InlineSpan>[
                        TextSpan(
                          text:
                              'Model:${scaleNetItems[index].scaleModel! == "TMax" ? "" : scaleNetItems[index].scaleModel!}\r\nSN:${scaleNetItems[index].scaleModel! == "TMax" ? "" : scaleNetItems[index].scaleSn!}\r\nPort:${scaleNetItems[index].port!}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    child: Text(
                      scaleNetItems[index].scaleName!,
                      maxLines: 1, // 设置文本最大行数为1
                      style: const TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          scaleNetItems[index].isOnline!
                              ? localizedStrings.gOnlineTip
                              : localizedStrings.gOfflineTip,
                          maxLines: 1, // 设置文本最大行数为1
                          style: TextStyle(
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                            color: scaleNetItems[index].isOnline!
                                ? Theme.of(context)
                                    .colorScheme
                                    .onTertiaryFixedVariant
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      const Icon(Icons.wifi)
                    ],
                  ),
                  selectedTileColor: Theme.of(context).colorScheme.primary,
                  trailing: Tooltip(
                    message: localizedStrings.rJoinManagementTip,
                    child: IconButton(
                        onPressed: () {
                          setScaleRelStatus(scaleNetItems[index].scaleId!,
                              getStatus(scaleNetItems[index].scaleId!));
                        },
                        icon: Icon(
                          getStatus(scaleNetItems[index].scaleId!)
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                  ),
                  onTap: () {},
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String tipStr) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: SizedBox(
            width: 300,
            height: 70,
            child: Text(
              tipStr,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: <Widget>[
            SizedBox(
              height: 30,
              child: OutlinedButton(
                child: Text(localizedStrings.gBtnConfirm),
                onPressed: () {
                  Navigator.of(context).pop(true); // 跳转
                },
              ),
            )
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {}
    });
  }

  Widget buildCardDetail(TransactionWithExpansion tran) {
    return Column(
      // children: tran.details.map((detail) {
      children: tran.details
          .where((detail) => detail.pluReturnFlag != "Cancel")
          .map((detail) {
        return Card(
          elevation: 1,
          child: ListTile(
            title: Row(
              children: [
                Text('PLU：${detail.pluNum}'),
                const Text('        '),
                Text('Name：${detail.pluName}'),
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
      child: Text(detail),
    );
  }

  Widget buildCartTitle(TransactionWithExpansion tran) {
    return Card(
      elevation: 1, //阴影宽度
      shadowColor: Theme.of(context).colorScheme.primary,
      child: ListTile(
        title: Row(
          children: [
            Text(
              '${tran.total.scaleModel}/${tran.total.scaleSn}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('        '),
            Text(
              'ID：${tran.total.settleAccountTimes}',
              style: const TextStyle(fontWeight: FontWeight.bold),
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

    var directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      dialogTitle: 'Output file:',
      type: FileType.custom,
      allowedExtensions: ['csv'],
      fileName: 'report.csv',
    ));
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('OK    ${file.path}'),
                backgroundColor:
                    Theme.of(context).colorScheme.onTertiaryFixedVariant),
          );
        }
      } catch (e) {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.toString()),
                backgroundColor: Theme.of(context).colorScheme.error),
          );
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
