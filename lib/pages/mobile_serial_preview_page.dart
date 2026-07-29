import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/no_device_widget.dart';

class MobileSerialPreviewPage extends StatefulWidget {
  final int selScaleId;
  const MobileSerialPreviewPage({
    super.key,
    required this.selScaleId,
  });

  @override
  State<MobileSerialPreviewPage> createState() =>
      _MobileSerialPreviewPageState();
}

class _MobileSerialPreviewPageState extends State<MobileSerialPreviewPage> {
  final List<String> outputData = [];
  bool isHexDisplay = false;
  late int activeScaleId;
  final ScrollController _scrollController = ScrollController();
  dynamic _eventbusListener;

  @override
  void initState() {
    super.initState();
    activeScaleId = widget.selScaleId;
    if (activeScaleId == -1 && myAllScalesList.isNotEmpty) {
      activeScaleId = myAllScalesList.first.scaleId!;
    }

    if (activeScaleId != -1) {
      PublicFunctions.getWeight(activeScaleId);
    }

    _eventbusListener = eventBus.on<EventScalePassthData>().listen((event) {
      if (mounted) {
        setState(() {
          final resp = event.obj;
          outputData.add(resp.msgBody);
          if (outputData.length > 1000) {
            outputData.clear();
          }
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _changeScale(int scaleId) {
    if (activeScaleId != -1) {
      PublicFunctions.stopWeight(activeScaleId);
    }
    setState(() {
      activeScaleId = scaleId;
      outputData.clear();
    });
    PublicFunctions.getWeight(activeScaleId);
  }

  @override
  void dispose() {
    _eventbusListener?.cancel();
    _scrollController.dispose();
    if (activeScaleId != -1) {
      PublicFunctions.stopWeight(activeScaleId);
    }
    super.dispose();
  }

  Widget _buildDeviceDrawer(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, top: 20, bottom: 16, right: 16),
              child: Text(
                localizedStrings?.gTitleDeviceList ?? "Device List",
                style: const TextStyle(
                  color: Color(0xFF005696),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: myAllScalesList.isEmpty
                  ? showNoDeviceWidget(context)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: myAllScalesList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final scale = myAllScalesList[index];
                        final bool isSelect = (activeScaleId == scale.scaleId);
                        final bool isOnline = scale.isOnline;

                        String iconPath = serialPortSvgIcon();
                        if (scale.tMedia == netScaleType) {
                          iconPath = networkSvgIcon();
                        } else if (scale.tMedia == btScaleType) {
                          iconPath = btSvgIcon();
                        }

                        final String displayName = scale.scaleName.isNotEmpty
                            ? scale.scaleName
                            : "Device No.${index + 1}";

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _changeScale(scale.scaleId!);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelect
                                  ? const Color(0xFF005696)
                                  : const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelect
                                        ? Colors.white.withOpacity(0.2)
                                        : const Color(0xFFE8EEF4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.center,
                                  child: getSvgIcon(
                                    iconPath,
                                    24,
                                    24,
                                    isSelect
                                        ? Colors.white
                                        : const Color(0xFF005696),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        displayName,
                                        style: TextStyle(
                                          color: isSelect
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isOnline
                                            ? (localizedStrings?.gTipOnline ??
                                                "Online")
                                            : (localizedStrings?.gTipOffline ??
                                                "Offline"),
                                        style: TextStyle(
                                          color: isOnline
                                              ? (isSelect
                                                  ? Colors.white
                                                      .withOpacity(0.8)
                                                  : const Color(0xFF005696))
                                              : Colors.redAccent,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDeviceDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 84,
        leading: Builder(
          builder: (BuildContext ctx) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BackButton(
                  color: Colors.black87,
                  onPressed: () => Navigator.pop(context),
                ),
                GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child:
                        getSvgIcon(weighingSvgIcon(), 24, 24, Colors.black87),
                  ),
                ),
              ],
            );
          },
        ),
        title: const Text(
          "Open preview",
          style: TextStyle(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                outputData.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: outputData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      outputData[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isHexDisplay = !isHexDisplay;
                    });
                    if (activeScaleId != -1) {
                      PublicFunctions.changeScalePassth(
                          isHexDisplay, activeScaleId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005696),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    isHexDisplay ? "ASCII" : "HEX",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
