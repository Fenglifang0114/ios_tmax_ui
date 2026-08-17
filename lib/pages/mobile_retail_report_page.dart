import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t_max/data/detail_info.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/pak_info_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/scalelist_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/show_error_dialog.dart';
import 'package:t_max/widget/mobile_scale_drawer_widget.dart';

class TransactionWithExpansion extends DetailInfoRev {
  bool isExpanded;
  TransactionWithExpansion({
    required super.total,
    required super.details,
    this.isExpanded = false,
  });
}

class MobileRetailReportPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String? lastRouteName;

  const MobileRetailReportPage({
    super.key,
    required this.onNavigate,
    this.lastRouteName,
  });

  @override
  State<MobileRetailReportPage> createState() => _MobileRetailReportPageState();
}

class _MobileRetailReportPageState extends State<MobileRetailReportPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  bool _isServiceStatusExpanded = false;
  bool exportFlag = true;

  final int serviceId = 999999999;
  List<int> mySelScaleIdList = [];
  List<TransactionWithExpansion> transactions = [];

  StreamSubscription? _eventBus1;
  StreamSubscription? _eventBus2;
  StreamSubscription? _eventBus3;
  StreamSubscription? _eventBusScaleSrvList;
  StreamSubscription? _eventBusScaleOnline;
  StreamSubscription? _eventBusScaleList;

  // Filtered network scales (WiFi, Bluetooth, Ethernet - tMedia != 0)
  List<Scale> get _networkScalesList {
    return myAllScalesList.where((scale) => scale.tMedia != 0).toList();
  }

  // Filtered transactions based on search query and selected scale IDs
  List<TransactionWithExpansion> get _filteredTransactions {
    final query = _searchController.text.trim().toLowerCase();
    return transactions.where((tran) {
      // Filter by search query if entered
      if (query.isNotEmpty) {
        final codeMatch = '${tran.total.scaleModel}/${tran.total.scaleSn}'.toLowerCase().contains(query);
        final idMatch = tran.total.settleAccountTimes.toString().contains(query);
        final pluMatch = tran.details.any((d) =>
            d.pluName.toLowerCase().contains(query) || d.pluNum.toLowerCase().contains(query));
        if (!codeMatch && !idMatch && !pluMatch) return false;
      }
      return true;
    }).toList();
  }

  Timer? _heartbeatTimer;

  void netScaleOpenBill() {
    if (myAllScalesList.isNotEmpty) {
      for (int i = 0; i < myAllScalesList.length; i++) {
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

  @override
  void initState() {
    super.initState();
    PublicFunctions.getScaleList();
    PublicFunctions.getScaleSrvList(serviceId);
    netScaleOpenBill();
    startHeartbeatTimer();
    PublicFunctions.getDetailList();

    // Listen to real transaction detail info response from backend SQLite DB
    _eventBus1 = eventBus.on<EventRespDetailInfo>().listen((event) {
      if (mounted) {
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

            // Sort transactions in descending order by created time
            transactions.sort((a, b) => b.total.createdAt.compareTo(a.total.createdAt));
          } catch (e) {
            if (kDebugMode) {
              print("[RETAIL_REPORT_PARSE_ERR] $e");
            }
          }
        });
      }
    });

    // Listen to bill tail arrival event (new transaction completed on scale)
    _eventBus2 = eventBus.on<EventRevDetailTail>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
          PublicFunctions.getDetailList();
        }
      }
    });

    // Listen to new detail added event
    _eventBus3 = eventBus.on<EventRespDetailAdd>().listen((event) {
      if (mounted) {
        PublicFunctions.getDetailList();
      }
    });

    // Listen to scale service list event
    _eventBusScaleSrvList = eventBus.on<EventRespScaleSrvList>().listen((event) {
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

    // Listen to scale online/offline updates
    _eventBusScaleOnline = eventBus.on<EventRespScaleOnline>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });

    // Listen to scale list updates
    _eventBusScaleList = eventBus.on<EventScaleList>().listen((event) {
      if (mounted) {
        netScaleOpenBill();
        setState(() {});
      }
    });

    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _eventBus1?.cancel();
    _eventBus2?.cancel();
    _eventBus3?.cancel();
    _eventBusScaleSrvList?.cancel();
    _eventBusScaleOnline?.cancel();
    _eventBusScaleList?.cancel();
    stopHeartbeatTimer();
    _searchController.dispose();
    super.dispose();
  }

  void addOrRemoveSelScale(int scaleId) {
    if (mySelScaleIdList.contains(scaleId)) {
      mySelScaleIdList.remove(scaleId);
    } else {
      mySelScaleIdList.add(scaleId);
      PublicFunctions.openBillSend(scaleId);
    }
    setScaleRelStatus(scaleId, getStatus(scaleId));
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

  String convertDateTime(String timestr) {
    try {
      DateTime originalTime = DateTime.parse(timestr);
      DateTime localTime = originalTime.toLocal();
      var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(localTime);
    } catch (e) {
      return timestr;
    }
  }

  Future<void> exportToCsv() async {
    if (!exportFlag) return;
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
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Output Folder',
      );

      if (selectedDirectory != null) {
        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        outputFile = "$selectedDirectory/report_$timestamp.csv";
      } else {
        exportFlag = true;
        return;
      }
    } else {
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
          showErrorDialog(context, 'Exported Successfully:\n${file.path}');
        }
      } catch (e) {
        if (mounted && context.mounted) {
          showErrorDialog(context, e.toString());
        }
      }
    }
    exportFlag = true;
  }

  @override
  Widget build(BuildContext context) {
    final recordList = _filteredTransactions;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDeviceListDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            _buildTopHeader(),

            // Service Status Row
            _buildServiceStatusRow(),

            // Search Box
            _buildSearchBox(),

            const SizedBox(height: 8),

            // Record List
            Expanded(
              child: recordList.isEmpty
                  ? Center(
                      child: Text(
                        localizedStrings?.gTipNoData ?? 'No Data',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: recordList.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF5F5F5),
                      ),
                      itemBuilder: (context, index) {
                        final item = recordList[index];
                        return _buildRecordRowItem(item);
                      },
                    ),
            ),

            // Bottom Action Bar (Refresh List + Export)
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (widget.lastRouteName != null &&
        widget.lastRouteName!.isNotEmpty &&
        widget.lastRouteName != '/retailReport') {
      widget.onNavigate(widget.lastRouteName!);
    } else {
      widget.onNavigate('/mobileData');
    }
  }

  // Top Header Bar: <- [ScaleIcon] Retail Report (?)
  Widget _buildTopHeader() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
            onPressed: _handleBack,
          ),
          MobileScaleHeaderIconButton(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          const SizedBox(width: 8),
          Text(
            localizedStrings?.menuRetailReport ?? 'Retail Report',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // Service Status Row with Expand Chevron
  Widget _buildServiceStatusRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            '${localizedStrings?.gTipServiceStatus ?? "Service Status"}: ',
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          Text(
            localizedStrings?.gTipServiceStarted ?? 'Service is running',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0D558E),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isServiceStatusExpanded = !_isServiceStatusExpanded;
              });
            },
            child: Icon(
              _isServiceStatusExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.black54,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // Search Box: [🔍 Please enter]
  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: localizedStrings?.gTipWait ?? 'Please enter',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Record Row Item in List (Mapped to real Transaction data)
  Widget _buildRecordRowItem(TransactionWithExpansion item) {
    final modelSn = '${item.total.scaleModel}/${item.total.scaleSn}';
    final timeStr = convertDateTime(item.total.createdAt.toString());

    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => MobileRetailReportDetailPage(
              transaction: item,
            ),
          ),
        );
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              modelSn.isNotEmpty ? modelSn : 'Scale',
              style: const TextStyle(
                color: Color(0xFF0D558E),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              timeStr,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Action Bar: [Refresh List] [Export]
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D558E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {
                  PublicFunctions.getDetailList();
                },
                child: Text(
                  localizedStrings?.rRefreshListBtn ?? 'Refresh List',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BB984),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: exportFlag ? exportToCsv : null,
                child: Text(
                  localizedStrings?.gBtnExport ?? 'Export',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Device List Left Slide Drawer
  Widget _buildDeviceListDrawer() {
    final netScales = _networkScalesList;

    return UnifiedDeviceDrawerContent(
      scaleList: netScales,
      isSelected: (scale) => mySelScaleIdList.contains(scale.scaleId),
      onScaleTap: (scale) {
        setState(() {
          addOrRemoveSelScale(scale.scaleId);
        });
      },
    );
  }
}

// Sub-Page: Details View for Single Real Transaction Record Item
class MobileRetailReportDetailPage extends StatelessWidget {
  final TransactionWithExpansion transaction;

  const MobileRetailReportDetailPage({
    super.key,
    required this.transaction,
  });

  String convertDateTime(String timestr) {
    try {
      DateTime originalTime = DateTime.parse(timestr);
      DateTime localTime = originalTime.toLocal();
      var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(localTime);
    } catch (e) {
      return timestr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final validDetails = transaction.details
        .where((d) => d.pluReturnFlag != "Cancel")
        .toList();

    final modelSn = '${transaction.total.scaleModel}/${transaction.total.scaleSn}';
    final settleId = 'ID:${transaction.total.settleAccountTimes}';
    final timeStr = convertDateTime(transaction.total.createdAt.toString());
    final totalAmount = transaction.total.totalPrice.toString();
    final payAmount = transaction.total.payPrice.toString();
    final taxType = transaction.total.taxKind.toString();
    final accCount = transaction.total.totalCount.toString();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.black87, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Total Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        modelSn.isNotEmpty ? modelSn : 'Scale',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D558E),
                        ),
                      ),
                      Text(
                        settleId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D558E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Summary Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryField('Time', timeStr),
                      _buildSummaryField('ToialAmount', totalAmount),
                      _buildSummaryField('Pay Amount', payAmount),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: _buildSummaryField('Tax Type', taxType),
                      ),
                      _buildSummaryField('ACC Count', accCount),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
                  const SizedBox(height: 16),

                  // PLU Items Breakdown
                  for (int i = 0; i < validDetails.length; i++) ...[
                    _buildPluItemSection(validDetails[i]),
                    if (i < validDetails.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPluItemSection(Detail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PLU:${detail.pluNum}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D558E),
              ),
            ),
            Text(
              'Name:${detail.pluName}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D558E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPillChip('Wgt: ${detail.pluTotalWeight}'),
            _buildPillChip('PCS:${detail.pluQuantity}'),
            _buildPillChip('PLU Unit: ${detail.pluUnit}'),
            _buildPillChip('Tare:${detail.pluTare}'),
            _buildPillChip('Unit Price: ${detail.pluUnitPrice}'),
            _buildPillChip('Tax Type: ${detail.pluTaxType}'),
            _buildPillChip('Tax Price: ${detail.pluTaxPrice}'),
            _buildPillChip('Change Type:${detail.pluChangeType}'),
            _buildPillChip('Return Flag:${detail.pluReturnFlag}'),
            _buildPillChip('Total Price:${detail.pluTotalPrice}'),
          ],
        ),
      ],
    );
  }

  Widget _buildPillChip(String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 13,
        ),
      ),
    );
  }
}
