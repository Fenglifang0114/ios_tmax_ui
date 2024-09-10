import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/custom_button.dart';
import '../data/comscaleinfo_data.dart';
import '../data/detail_info.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../widget/page_head.dart';

class TransactionReportPage extends StatefulWidget {
  const TransactionReportPage({super.key});

  @override
  _TransactionReportPageState createState() => _TransactionReportPageState();
}

class _TransactionReportPageState extends State<TransactionReportPage> {
  final ScrollController _scrollController = ScrollController();
  late final ScrollController _scrollController1 = ScrollController();

  List<TransactionWithExpansion> transactions = [];

  dynamic eventBus1;
  dynamic eventBus2;
  bool exportFlag = true;
  bool isRefresh = false;

  @override
  void initState() {
    netScaleOpenBill();
    PublicFunctions.getDetailList();
    isRefresh = true;
    eventBus1 = eventBus.on<EventRespDetailInfo>().listen((event) {
      String detailStr = event.obj;
      if (mounted) {
        isRefresh = false;
        setState(() {
          try {
            final detailInfoRev = detailInfoRevFromJson(detailStr);
            transactions = detailInfoRev.map((detail) {
              return TransactionWithExpansion(
                total: detail.total,
                details: detail.details,
              );
            }).toList();
          } catch (e) {}
        });
      }
    });
    eventBus2 = eventBus.on<EventRevDetailTail>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
          PublicFunctions.getDetailList();
          isRefresh = true;
        }
      }
    });

    super.initState();
  }

  void netScaleOpenBill() {
    if (myNetScaleList.isNotEmpty) {
      for (int i = 0; i < myNetScaleList.length; i++) {
        PublicFunctions.openBillSend(myNetScaleList[i].scaleId!);
      }
    }
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus2.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxheight = MediaQuery.of(context).size.height;

    transactions.sort((a, b) => b.total.createdAt.compareTo(a.total.createdAt));
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            child: pageHeadDesign(
                context, localizedStrings.re_detail_report_title, []),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomOutlinedButton(
                    btnWidth: 200,
                    btnHeight: 50,
                    icon: Icons.refresh,
                    text: "Refresh ",
                    onPressed: isRefresh
                        ? null
                        : () {
                            PublicFunctions.getDetailList();
                            isRefresh = true;
                          }),
                SizedBox(
                  width: 20,
                ),
                CustomOutlinedButton(
                    btnWidth: 200,
                    btnHeight: 50,
                    icon: Icons.save,
                    text: "Export CSV ",
                    onPressed: exportFlag ? exportToCsv : null)
              ],
            ),
            SizedBox(
              width: maxWidth,
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
                                      buildCartDetail(transactions[index]),
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
        ));
  }

  Widget buildCartDetail(TransactionWithExpansion tran) {
    return Column(
      children: tran.details.map((detail) {
        return Card(
          elevation: 1,
          child: ListTile(
            title: Row(
              children: [
                Text('PLU：${detail.pluNum}'),
                Text('        '),
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
            Text('        '),
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
        ''
      ];
      data.add(row);

      for (var detail in transaction.details) {
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
          detail.pluChangeType,
          detail.pluTotalPrice,
        ];
        data.add(row);
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
      final filePath = outputFile;
      File file = File(filePath);
      try {
        await file.writeAsString(
          List.generate(data.length, (index) => data[index].join(','))
              .join('\n'),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('OK    ${file.path}'),
              backgroundColor: Theme.of(context).colorScheme.outline),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
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
