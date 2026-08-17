import 'package:flutter/material.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/icons.dart';

/// 手机端 AppBar 中统一的矩形带框秤图标按钮组件（位于返回箭头正右侧）
class MobileScaleHeaderIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final double width;
  final double height;

  const MobileScaleHeaderIconButton({
    super.key,
    required this.onTap,
    this.width = 38.0,
    this.height = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: getSvgIcon(
          weighingSvgIcon(),
          20,
          20,
          const Color(0xFF1E293B),
        ),
      ),
    );
  }
}

/// 手机端统一的设备列表抽屉组件（参照图1设计规范）
class UnifiedDeviceDrawerContent extends StatelessWidget {
  final List<Scale> scaleList;
  final bool Function(Scale scale) isSelected;
  final Function(Scale scale) onScaleTap;
  final String? title;

  const UnifiedDeviceDrawerContent({
    super.key,
    required this.scaleList,
    required this.isSelected,
    required this.onScaleTap,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    String drawerTitle = title ?? (localizedStrings?.gTitleDeviceList ?? localizedStrings?.fScaleList ?? "Device List");

    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 抽屉头部标题
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 16, right: 16),
              child: Text(
                drawerTitle,
                style: const TextStyle(
                  color: Color(0xFF005696),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),

            // 秤列表
            Expanded(
              child: scaleList.isEmpty
                  ? Center(
                      child: Text(
                        localizedStrings?.gTipNoDevice ?? "No Devices",
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: scaleList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        Scale scale = scaleList[index];
                        bool checked = isSelected(scale);
                        bool isOnline = scale.isOnline;

                        String iconPath = serialPortSvgIcon();
                        if (scale.tMedia == netScaleType) {
                          iconPath = networkSvgIcon();
                        } else if (scale.tMedia == btScaleType) {
                          iconPath = btSvgIcon();
                        }

                        String displayName = scale.scaleName.isNotEmpty
                            ? scale.scaleName
                            : "Device No.${scale.scaleId}";

                        return GestureDetector(
                          onTap: () => onScaleTap(scale),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: checked ? const Color(0xFF005696) : const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                // 左侧 Icon Box
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: checked
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : const Color(0xFFE8EEF4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: getSvgIcon(
                                    iconPath,
                                    24,
                                    24,
                                    checked ? Colors.white : const Color(0xFF005696),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // 秤名称与在线状态
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        displayName,
                                        style: TextStyle(
                                          color: checked ? Colors.white : const Color(0xFF1E293B),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isOnline
                                            ? (localizedStrings?.gTipOnline ?? "Online")
                                            : (localizedStrings?.gTipOffline ?? "Offline"),
                                        style: TextStyle(
                                          color: checked
                                              ? Colors.white.withValues(alpha: 0.85)
                                              : (isOnline
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFFEF4444)),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
}
