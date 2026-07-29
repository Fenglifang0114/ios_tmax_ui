import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/pages/mobile_receipt_variable_edit_page.dart';
import 'package:t_max/pages/mobile_sel_scales_page.dart';
import 'package:t_max/pages/update_firmware_page.dart';

class MobileReceiptVariableSettingPage extends StatefulWidget {
  const MobileReceiptVariableSettingPage({super.key});

  @override
  State<MobileReceiptVariableSettingPage> createState() =>
      _MobileReceiptVariableSettingPageState();
}

class _MobileReceiptVariableSettingPageState
    extends State<MobileReceiptVariableSettingPage> {
  // Exact PC fields matching HeaderFooterPage
  final Map<String, List<String>> _groupedFields = {
    "Header": ["Header 1", "Header 2", "Header 3"],
    "Footer": ["Footer 1", "Footer 2", "Footer 3"],
    "Operator": ["Operator 1", "Operator 2", "Operator 3", "Operator 4"],
  };

  final Map<String, String> _fieldValues = {
    "Header 1": "Display company name...",
    "Header 2": "",
    "Header 3": "",
    "Footer 1": "",
    "Footer 2": "",
    "Footer 3": "",
    "Operator 1": "",
    "Operator 2": "",
    "Operator 3": "",
    "Operator 4": "",
  };

  void _handleDownload() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => MobileSelectScalesPage(
          funcNo: comScaleSerialSend,
          sendMsgStr: '',
          jsonList: const [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Variable Value Setting",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _groupedFields.keys.length,
              itemBuilder: (ctx, groupIdx) {
                final groupName = _groupedFields.keys.elementAt(groupIdx);
                final fields = _groupedFields[groupName]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      groupName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...fields.map((field) {
                      final val = _fieldValues[field] ?? "";

                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            field,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                val.isNotEmpty ? val : "Please enter",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: val.isNotEmpty
                                      ? Colors.black87
                                      : Colors.black38,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.black45,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => MobileReceiptVariableEditPage(
                                  title: field,
                                  initialValue: val,
                                  onConfirm: (updatedValue) {
                                    setState(() {
                                      _fieldValues[field] = updatedValue;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),

          // Bottom Action Button: Download (Primary Blue #005696)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005696),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    "Download",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
