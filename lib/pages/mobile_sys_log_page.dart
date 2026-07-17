import 'package:flutter/material.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/pages/mobile_log_cal_tab.dart';
import 'package:t_max/pages/mobile_log_sys_tab.dart';
import 'package:t_max/pages/mobile_log_wgt_tab.dart';

class MobileSysLogPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;

  const MobileSysLogPage({
    super.key,
    required this.onNavigate,
    required this.lastRouteName,
  });

  @override
  State<MobileSysLogPage> createState() => _MobileSysLogPageState();
}

class _MobileSysLogPageState extends State<MobileSysLogPage> {
  int _currentIndex = 0; // 0: Calibration, 1: System, 2: Weighing
  final List<String> _tabNames = [
    localizedStrings?.calibrationRecords ?? "Calibration Records",
    localizedStrings?.systemRecords ?? "System Records",
    localizedStrings?.weighingRecords ?? "Weighing Records",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabNames[0] = localizedStrings?.calibrationRecords ?? "Calibration Records";
    _tabNames[1] = localizedStrings?.systemRecords ?? "System Records";
    _tabNames[2] = localizedStrings?.weighingRecords ?? "Weighing Records";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            widget.onNavigate('/multiScaleManagement');
          },
        ),
        title: Text(
          localizedStrings?.logManagement ?? "Log Management",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          MobileLogCalTab(
            contentType: '',
            currentIndex: _currentIndex,
            onTabChanged: (index) => setState(() => _currentIndex = index),
          ),
          MobileLogSysTab(
            contentType: '',
            currentIndex: _currentIndex,
            onTabChanged: (index) => setState(() => _currentIndex = index),
          ),
          if (mySysUser.roleId == superAdminRoleId || mySysUser.roleId == adminRoleId)
            MobileLogWgtTab(
              contentType: '',
              currentIndex: _currentIndex,
              onTabChanged: (index) => setState(() => _currentIndex = index),
            )
          else
            const Center(child: Text("No Permission")),
        ],
      ),
    );
  }
}
