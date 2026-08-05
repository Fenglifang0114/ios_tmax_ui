import 'package:flutter/material.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/widget/fma_parameter_setting.dart';

class MobileParameterSettingsPage extends StatefulWidget {
  final bool autoTare;
  final bool autoNextStep;
  final int stableTime;
  final bool checkCode;

  const MobileParameterSettingsPage({
    super.key,
    required this.autoTare,
    required this.autoNextStep,
    required this.stableTime,
    required this.checkCode,
  });

  @override
  State<MobileParameterSettingsPage> createState() =>
      _MobileParameterSettingsPageState();
}

class _MobileParameterSettingsPageState
    extends State<MobileParameterSettingsPage> {
  late bool _checkCode;
  late bool _autoTare;
  late bool _autoNextStep;
  late int _stableTime;

  final List<int> _stableTimeOptions = [1, 2, 5, 10];

  @override
  void initState() {
    super.initState();
    _checkCode = widget.checkCode;
    _autoTare = widget.autoTare;
    _autoNextStep = widget.autoNextStep;
    _stableTime = widget.stableTime;
  }

  void _showStableTimePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizedStrings?.gTipStableTime ?? 'Stable Time (s)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ..._stableTimeOptions.map((time) {
                  bool isSelected = _stableTime == time;
                  return ListTile(
                    title: Text(
                      '$time s',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF00B074) : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF00B074))
                        : null,
                    onTap: () {
                      setState(() {
                        _stableTime = time;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF00B074),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStableTimeRow() {
    return InkWell(
      onTap: _showStableTimePicker,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizedStrings?.gTipStableTime ?? 'Stable Time (s)',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Text(
                  '$_stableTime',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          localizedStrings?.gParameterSettingsTitle ?? 'Parameter settings',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSwitchRow(
                    localizedStrings?.ingredientVerification ?? 'Ingredient Verification',
                    _checkCode,
                    (val) => setState(() => _checkCode = val),
                  ),
                  const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
                  _buildSwitchRow(
                    localizedStrings?.gTipAutoTare ?? 'Auto Tare',
                    _autoTare,
                    (val) => setState(() => _autoTare = val),
                  ),
                  const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
                  _buildSwitchRow(
                    localizedStrings?.gTipAutoNextStep ?? 'Auto Next Step',
                    _autoNextStep,
                    (val) => setState(() => _autoNextStep = val),
                  ),
                  const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
                  _buildStableTimeRow(),
                  const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
                ],
              ),
            ),
            // Bottom Fixed Confirm Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      FmaSettingInfo(
                        _autoNextStep,
                        _autoTare,
                        _stableTime,
                        _checkCode,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B074),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    localizedStrings?.gBtnConfirm ?? 'Confirm',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
