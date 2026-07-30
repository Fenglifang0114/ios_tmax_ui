import 'package:flutter/material.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/log_data.dart';
import 'package:intl/intl.dart';
import 'package:t_max/functions/methods.dart';

class MobileLogDetailPage extends StatelessWidget {
  final dynamic log;
  final String logType; // 'sys', 'cal', 'wgt'

  const MobileLogDetailPage({
    super.key,
    required this.log,
    required this.logType,
  });

  String _getRoleName(int? roleId) {
    if (roleId == 1) return localizedStrings?.superAdmin ?? "Super Admin";
    if (roleId == 2) return localizedStrings?.admin ?? "Admin";
    if (roleId == 3) return localizedStrings?.operator ?? "Operator";
    return "";
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Theme.of(context).colorScheme.surfaceContainerHighest),
      ],
    );
  }

  Widget _buildDetailsBlock(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCalLogDetails(BuildContext context, CalLog calLog) {
    return [
      _buildDetailRow(context, 'ID', calLog.recId?.toString().padLeft(2, '0') ?? ""),
      _buildDetailRow(context, localizedStrings?.operator ?? "Operator", calLog.operator ?? ""),
      _buildDetailRow(context, localizedStrings?.userRole ?? "Role", _getRoleName(calLog.roleId)),
      _buildDetailRow(context, localizedStrings?.calibrationType ?? "Calibration Type", getCalLogTrans(calLog.type ?? "")),
      _buildDetailRow(context, localizedStrings?.calibrationMode ?? "Calibration Mode", calLog.mode ?? ""),
      _buildDetailRow(context, localizedStrings?.gTipWeightUnit ?? "Weight Unit", calLog.unit ?? ""),
      _buildDetailRow(context, localizedStrings?.calibrationValue ?? "Calibration Value", calLog.calValue ?? ""),
      _buildDetailRow(context, localizedStrings?.weightBeforeCalibration ?? "Weight Before Calibration", calLog.before ?? ""),
      _buildDetailRow(context, localizedStrings?.weightAfterCalibration ?? "Weight After Calibration", calLog.after ?? ""),
      _buildDetailRow(context, localizedStrings?.calibrationError ?? "Calibration Error", calLog.calError ?? ""),
      _buildDetailRow(context, localizedStrings?.gTipResult ?? "Result", getCalLogTrans(calLog.calResult ?? "")),
      _buildDetailRow(context, localizedStrings?.gDeviceName ?? "Device name", calLog.scaleName ?? ""),
      _buildDetailRow(context, localizedStrings?.gModelName ?? "Model Name", calLog.modelName ?? ""),
      _buildDetailRow(context, localizedStrings?.gScaleSn ?? "SN", calLog.sn ?? ""),
      _buildDetailRow(context, localizedStrings?.fCreatedAtCol ?? "Create Time", calLog.createTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(calLog.createTime!) : ""),
    ];
  }

  List<Widget> _buildSysLogDetails(BuildContext context, SysLog sysLog) {
    return [
      _buildDetailRow(context, 'ID', sysLog.recId?.toString().padLeft(2, '0') ?? ""),
      _buildDetailRow(context, localizedStrings?.operator ?? "Operator", sysLog.operator ?? ""),
      _buildDetailRow(context, localizedStrings?.userRole ?? "Role", _getRoleName(sysLog.roleId)),
      _buildDetailRow(context, localizedStrings?.module ?? "Module", getSysLogTrans(sysLog.module ?? "")),
      _buildDetailRow(context, localizedStrings?.funcName ?? "Function Module", getSysLogTrans(sysLog.funcName ?? "")),
      _buildDetailRow(context, localizedStrings?.operationType ?? "Operation Type", getSysLogTrans(sysLog.operationType ?? "")),
      _buildDetailRow(context, localizedStrings?.gTipResult ?? "Result", getSysLogTrans(sysLog.result ?? "")),
      _buildDetailRow(context, localizedStrings?.fCreatedAtCol ?? "Create Time", sysLog.createTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(sysLog.createTime!) : ""),
      if (sysLog.remarks != null && sysLog.remarks!.isNotEmpty)
        _buildDetailsBlock(context, localizedStrings?.details ?? "Details", sysLog.remarks!),
    ];
  }

  List<Widget> _buildWgtLogDetails(BuildContext context, ScaleWgtInfo wgtLog) {
    return [
      _buildDetailRow(context, 'ID', wgtLog.recId?.toString().padLeft(2, '0') ?? ""),
      _buildDetailRow(context, localizedStrings?.operator ?? "Operator", wgtLog.operator ?? ""),
      _buildDetailRow(context, localizedStrings?.userRole ?? "Role", _getRoleName(wgtLog.roleId)),
      _buildDetailRow(context, localizedStrings?.module ?? "Module", getWgtLogTrans(wgtLog.module ?? "")),
      _buildDetailRow(context, localizedStrings?.fTotalWeight ?? "Total weight", wgtLog.weight ?? ""),
      _buildDetailRow(context, localizedStrings?.gTipWeightUnit ?? "Weight Unit", wgtLog.unit ?? ""),
      _buildDetailRow(context, localizedStrings?.gDeviceName ?? "Device name", wgtLog.scaleName ?? ""),
      _buildDetailRow(context, localizedStrings?.gModelName ?? "Model Name", wgtLog.modelName ?? ""),
      _buildDetailRow(context, localizedStrings?.gScaleSn ?? "SN", wgtLog.sn ?? ""),
      _buildDetailRow(context, localizedStrings?.fCreatedAtCol ?? "Create Time", wgtLog.createTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(wgtLog.createTime!) : ""),
      if (wgtLog.remarks != null && wgtLog.remarks!.isNotEmpty)
        _buildDetailsBlock(context, localizedStrings?.details ?? "Details", wgtLog.remarks!),
    ];
  }

  void _deleteWgtLog(BuildContext context, ScaleWgtInfo wgtLog) {
    if (wgtLog.recId == null) return;
    showDeleteDialog(() {
      ReqDelLogs reqDelLogs = ReqDelLogs(recId: [wgtLog.recId!]);
      PublicFunctions.deleteWgtLog(reqDelLogsToJson(reqDelLogs));
      Navigator.pop(context); // Close the detail page after delete
    }, localizedStrings?.tipDelLogs ?? "Confirm deletion?", context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];
    if (logType == 'cal' && log is CalLog) {
      content = _buildCalLogDetails(context, log);
    } else if (logType == 'sys' && log is SysLog) {
      content = _buildSysLogDetails(context, log);
    } else if (logType == 'wgt' && log is ScaleWgtInfo) {
      content = _buildWgtLogDetails(context, log);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizedStrings?.logDetails ?? "Log Details",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: content,
              ),
            ),
          ),
          if (logType == 'wgt' && log is ScaleWgtInfo)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).colorScheme.surface,
              child: ElevatedButton(
                onPressed: () => _deleteWgtLog(context, log),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF5350), // Red color
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  localizedStrings?.delete ?? "Delete",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
