import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/log_data.dart';
import 'package:t_max/widget/dialog_head_style.dart';

class SyslogDetailDialog extends StatelessWidget {
  final SysLog log;

  const SyslogDetailDialog({super.key, required this.log});

  Widget showText(BuildContext context, String text, Color color) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.apply(
            color: color,
          ),
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        width: 610,
        height: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withAlpha(50),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部
            ...dialogHeadStyle(context, (localizedStrings?.logDetails ?? "logDetails"), true,
                onClose: () {
              Navigator.of(context).pop();
            }),

            // 内容区域
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 基本信息区域
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.module ?? "module")}:',
                      value: getSysLogTrans(log.module ?? ""),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.funcName ?? "funcName")}:',
                      value: getSysLogTrans(log.funcName ?? ""),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.operationType ?? "operationType")}:',
                      value: getSysLogTrans(log.operationType ?? ""),
                    ),

                    // 操作标签
                    SizedBox(
                        height: 36,
                        child: Row(
                          children: [
                            showText(
                              context,
                              '${(localizedStrings?.operation ?? "operation")}:',
                              Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            Spacer(),
                          ],
                        )),

                    SizedBox(height: 8),

                    // 操作内容区域
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(smallPadding),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            log.operation?.trim() ?? "",
                            style: Theme.of(context).textTheme.bodySmall?.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ),

                    // 底部信息（可选）
                    if (log.createTime != null) ...[
                      SizedBox(height: regularPadding),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(smallPadding),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            SizedBox(width: 6),
                            showText(
                              context,
                              ' ${DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createTime!)}',
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                            Spacer(),
                            if (log.operator != null)
                              showText(
                                context,
                                log.operator.toString(),
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// 辅助组件：信息行
  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Container(
      height: 36,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: showText(
              context,
              label,
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: showText(
              context,
              value.isNotEmpty ? value : "",
              Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class CalLogDetailDialog extends StatelessWidget {
  final CalLog log;

  const CalLogDetailDialog({super.key, required this.log});

  Widget showText(BuildContext context, String text, Color color) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.apply(
            color: color,
          ),
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        width: 610,
        height: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withAlpha(50),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部
            ...dialogHeadStyle(context, (localizedStrings?.logDetails ?? "logDetails"), true,
                onClose: () {
              Navigator.of(context).pop();
            }),

            // 内容区域
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 基本信息区域
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.calibrationType ?? "calibrationType")}:',
                      value: getCalLogTrans(log.type ?? ""),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.gTipWeightUnit ?? "gTipWeightUnit")}:',
                      value: (log.unit ?? ""),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.calibrationValue ?? "calibrationValue")}:',
                      value: log.calValue.toString(),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.weightBeforeCalibration ?? "weightBeforeCalibration")}:',
                      value: log.before.toString(),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.weightAfterCalibration ?? "weightAfterCalibration")}:',
                      value: log.after.toString(),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.calibrationError ?? "calibrationError")}:',
                      value: log.calError.toString(),
                    ),
                    Spacer(),

                    SizedBox(height: 8),

                    // 底部信息（可选）
                    if (log.createTime != null) ...[
                      SizedBox(height: regularPadding),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(smallPadding),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            SizedBox(width: 6),
                            showText(
                              context,
                              ' ${DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createTime!)}',
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                            Spacer(),
                            if (log.operator != null)
                              showText(
                                context,
                                log.operator.toString(),
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// 辅助组件：信息行
  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Container(
      height: 36,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: showText(
              context,
              label,
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: showText(
              context,
              value.isNotEmpty ? value : "",
              Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class WgtLogDetailDialog extends StatelessWidget {
  final ScaleWgtInfo log;

  const WgtLogDetailDialog({super.key, required this.log});

  Widget showText(BuildContext context, String text, Color color) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.apply(
            color: color,
          ),
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        width: 610,
        height: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withAlpha(50),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部
            ...dialogHeadStyle(context, (localizedStrings?.logDetails ?? "logDetails"), true,
                onClose: () {
              Navigator.of(context).pop();
            }),

            // 内容区域
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 基本信息区域
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.module ?? "module")}:',
                      value: getWgtLogTrans(log.module ?? ""),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.fTotalWeight ?? "fTotalWeight")}:',
                      value: log.weight.toString(),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.gTipWeightUnit ?? "gTipWeightUnit")}:',
                      value: (log.unit ?? ""),
                    ),

                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.gDeviceName ?? "gDeviceName")}:',
                      value: log.scaleName.toString(),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: '${(localizedStrings?.gModelName ?? "gModelName")}:',
                      value: log.modelName.toString(),
                    ),
                    _buildInfoRow(
                      context: context,
                      label: 'SN:',
                      value: log.sn.toString(),
                    ),
                    Spacer(),

                    SizedBox(height: 8),

                    // 底部信息（可选）
                    if (log.createTime != null) ...[
                      SizedBox(height: regularPadding),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(smallPadding),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            SizedBox(width: 6),
                            showText(
                              context,
                              ' ${DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createTime!)}',
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                            Spacer(),
                            if (log.operator != null)
                              showText(
                                context,
                                log.operator.toString(),
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// 辅助组件：信息行
  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Container(
      height: 36,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: showText(
              context,
              label,
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: showText(
              context,
              value.isNotEmpty ? value : "",
              Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
