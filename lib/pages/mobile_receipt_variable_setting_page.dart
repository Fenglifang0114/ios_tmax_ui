import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/header_footer.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/data/writelog.dart';
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
  final Map<String, List<String>> _groupedFields = {
    "Header": ["Header 1", "Header 2", "Header 3"],
    "Footer": ["Footer 1", "Footer 2", "Footer 3"],
    "Operator": ["Operator 1", "Operator 2", "Operator 3", "Operator 4"],
  };

  final Map<String, String> _fieldValues = {
    "Header 1": "",
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

  List<MyvariableData> _varList = [];

  @override
  void initState() {
    super.initState();
    _openVarListJson();
  }

  void _openVarListJson() async {
    try {
      final ByteData bytes =
          await rootBundle.load('assets/template/modify_var.json');
      final jsonString = utf8.decode(bytes.buffer.asUint8List());
      Map<String, dynamic> jsonDataMap = json.decode(jsonString);
      var data = jsonDataMap['Print_var'] as List;
      setState(() {
        _varList = data.map((e) => MyvariableData.fromJson(e)).toList();
      });
    } catch (e) {
      debugPrint("Error loading modify_var.json: $e");
    }
  }

  int? _getVarId(String fieldName) {
    String keyName = fieldName.replaceAll(" ", "");
    var data = _varList.firstWhere(
      (element) => element.valuename == keyName,
      orElse: () =>
          MyvariableData(valuename: '', id: -1, comment: '', maxLen: 0),
    );
    return data.id != -1 ? data.id : null;
  }

  void _handleDownload() {
    HeaderFooterList headerFooterList = HeaderFooterList([]);
    _fieldValues.forEach((field, val) {
      if (val.trim().isNotEmpty) {
        int? varId = _getVarId(field);
        if (varId != null) {
          headerFooterList.listData.add(HeaderFooterData(varId, val.trim()));
        }
      }
    });

    if (headerFooterList.listData.isEmpty) {
      showTipInfo("Please enter at least one variable value to download", context);
      return;
    }

    ScaleCmd cmd = ScaleCmd('modify_var_value', json.encode(headerFooterList));
    String sendMsgStr = jsonEncode(cmd);
    writelog("[MobileVariableSetting] Prepared sendMsgStr: $sendMsgStr");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => MobileSelectScalesPage(
          funcNo: normalSend,
          sendMsgStr: sendMsgStr,
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

class MyvariableData {
  final String valuename;
  final int id;
  final String comment;
  final int maxLen;

  MyvariableData({
    required this.valuename,
    required this.id,
    required this.comment,
    required this.maxLen,
  });

  factory MyvariableData.fromJson(Map<String, dynamic> json) {
    return MyvariableData(
      valuename: json['valuename'] ?? '',
      id: json['id'] ?? -1,
      comment: json['comment'] ?? '',
      maxLen: json['maxLen'] ?? 0,
    );
  }
}
