// ignore_for_file: invalid_use_of_protected_member
part of 'multi_scale_management_page.dart';

extension MultiScaleManagementEditExt on MultiScaleManagementState {
  showEditWifiInfo(double maxWidth) {
    return Column(children: [
      subTitleInfo(context, (maxWidth - (maxWidth < 600 ? 60 : headWidthPadding)).clamp(100.0, maxWidth),
          localizedStrings.gBtnModify, localizedStrings.gTipScaleMgrPageHelp),
      Expanded(
        child: showEditNetScaleInfo(),
      ),
    ]);
  }

  Widget showEditNetScaleInfo() {
    return ListView(
      children: [
        SizedBox(
          height: regularPadding,
        ),
        buildItemInfo(
            showItemNameWithStar(context, localizedStrings.gIpAddress, false),
            showInputBox(context, ipCtl, '', (value) {
              setState(() {});
            }, true),
            showItemNameWithStar(context, localizedStrings.gTipPort, false),
            Container(
              height: inputHeight,
              padding: const EdgeInsets.only(left: 16, right: 20),
              decoration: BoxDecoration(
                border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
                borderRadius: BorderRadius.circular(0), // 设置圆角
              ),
              child: TextField(
                controller: portCtl,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, // 设置提示文本颜色
                  ),
                  border: InputBorder.none, // 移除默认边框
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.allow(RegExp(
                      r'^([1-9]|[1-9]\d|[1-9]\d{2}|[1-9]\d{3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$')), // 允许输入数字
                ],
                style: Theme.of(context).textTheme.bodySmall!.apply(
                      color:
                          Theme.of(context).colorScheme.onSurface, // 设置输入文本颜色
                    ),
                onChanged: (value) {
                  setState(() {});
                }, // 监听文本变化,
              ),
            )),
        SizedBox(
          height: regularPadding,
        ),
        SizedBox(
          height: regularPadding,
        ),
        SizedBox(
          height: regularPadding,
        ),
        SizedBox(
          height: regularPadding,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showTextButton(
                context,
                btnHeight,
                localizedStrings.gBtnConfirm,
                portCtl.text.isNotEmpty && _isValidIP
                    ? () {
                        editNetScale();
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: regularPadding),
            showTextButton(context, btnHeight, localizedStrings.gBtnCancel, () {
              setState(() {
                editWifiInfo = false;
              });
            },
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.onSurfaceVariant,
                Theme.of(context).colorScheme.onPrimary),
          ],
        )
      ],
    );
  }

}
