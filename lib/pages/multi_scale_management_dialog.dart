import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/icons.dart';

// 新增秤的弹窗
class AddScaleDialog extends StatefulWidget {
  const AddScaleDialog({super.key});
  @override
  AddScaleDialogState createState() => AddScaleDialogState();
}

class AddScaleDialogState extends State<AddScaleDialog> {
  bool isComHovered = false;
  bool isWifiHovered = false;
  bool isBtHovered = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 493,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            Container(
                height: dialogTitleheight,
                padding: const EdgeInsets.only(
                    left: largePadding, right: largePadding),
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: regularPadding,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        (localizedStrings?.gTitleAddDevice ?? "gTitleAddDevice"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                      onPressed: () {
                        Navigator.pop(context, '');
                      })
                ])),

            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            // 中部
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(26),
                  height: 150,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: MouseRegion(
                            onEnter: (_) => setState(() => isWifiHovered = true),
                            onExit: (_) => setState(() => isWifiHovered = false),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context, 'wifi');
                              },
                              child: Container(
                                  height: 120,
                                alignment: Alignment.center,
                                color: isWifiHovered
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      getSvgIcon(
                                          networkSvgIcon(),
                                          btnHeight,
                                          btnHeight,
                                          isWifiHovered
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                      SizedBox(
                                        height: regularPadding,
                                      ),
                                      Text(
                                        (localizedStrings?.gNetwork ?? "gNetwork"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .apply(
                                                color: isWifiHovered
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                      )
                                    ])),
                          ),
                        ),
                      ),
                        Expanded(
                          child: MouseRegion(
                            onEnter: (_) => setState(() => isComHovered = true),
                            onExit: (_) => setState(() => isComHovered = false),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context, 'com');
                              },
                              child: Container(
                                  height: 120,
                                alignment: Alignment.center,
                                color: isComHovered
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      getSvgIcon(
                                          serialPortSvgIcon(),
                                          btnHeight,
                                          btnHeight,
                                          isComHovered
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                      SizedBox(
                                        height: regularPadding,
                                      ),
                                      Text(
                                        (localizedStrings?.gSerialPort ?? "gSerialPort"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .apply(
                                                color: isComHovered
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                      )
                                    ])),
                          ),
                        ),
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        Expanded(
                          child: MouseRegion(
                            onEnter: (_) => setState(() => isBtHovered = true),
                            onExit: (_) => setState(() => isBtHovered = false),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context, 'bt');
                              },
                              child: Container(
                                  height: 120,
                                alignment: Alignment.center,
                                color: isBtHovered
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      getSvgIcon(
                                          btSvgIcon(),
                                          btnHeight,
                                          btnHeight,
                                          isBtHovered
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                      SizedBox(
                                        height: regularPadding,
                                      ),
                                      Text(
                                        (localizedStrings?.bluetooth ?? "bluetooth"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .apply(
                                                color: isBtHovered
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                      )
                                    ])),
                          ),
                        ),
                      ),
                      ])),
            ),
            Container(
                height: 140,
                color: Theme.of(context).colorScheme.surface,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(left: 50, right: 50),
                child: SelectableText(
                  (localizedStrings?.gTipAddDevice ?? "gTipAddDevice"),
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                )),
          ],
        ),
      ),
    );
  }
}
