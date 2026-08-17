import 'package:flutter/material.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/mobile_scale_drawer_widget.dart';

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
  dynamic _eventbusReqWeight;

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

    _eventbusReqWeight = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        final req = event.obj;
        if (req.scaleId == activeScaleId) {
          PublicFunctions.openScalePassth(activeScaleId);
        }
      }
    });

    _eventbusListener = eventBus.on<EventScalePassthData>().listen((event) {
      if (mounted) {
        setState(() {
          final resp = event.obj;
          if (resp.scaleId == activeScaleId || resp.scaleId == null) {
            outputData.add(resp.msgBody);
            if (outputData.length > 1000) {
              outputData.clear();
            }
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
    _eventbusReqWeight?.cancel();
    _scrollController.dispose();
    if (activeScaleId != -1) {
      PublicFunctions.stopWeight(activeScaleId);
    }
    super.dispose();
  }

  Widget _buildDeviceDrawer(BuildContext context) {
    return UnifiedDeviceDrawerContent(
      scaleList: myAllScalesList,
      isSelected: (scale) => activeScaleId == scale.scaleId,
      onScaleTap: (scale) {
        Navigator.pop(context);
        _changeScale(scale.scaleId!);
      },
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
        leadingWidth: 96,
        leading: Builder(
          builder: (BuildContext ctx) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 4),
                BackButton(
                  color: Colors.black87,
                  onPressed: () => Navigator.pop(context),
                ),
                MobileScaleHeaderIconButton(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
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
