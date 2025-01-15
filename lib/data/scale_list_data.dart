// 称重时秤的列表（实时称重界面，重量收集界面，检重界面，加法秤界面，减法秤界面）
//公用的信息

import 'package:flutter/material.dart';
import '../eventbus/eventbus.dart';
import 'comscaleinfo_data.dart';
import 'language.dart';

Widget myWeighingScaleListDrawer(BuildContext context, String title,
    List<NetScaleInfoLocal> scaleNetItems, int selScaleId) {
  return Column(
    children: [
      SizedBox(
        height: 50, // 设置抽屉头部高度为100像素
        child: Container(
          color: Theme.of(context).colorScheme.primary,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      showComScale(context, selScaleId),
      showNetScaleList(scaleNetItems, selScaleId)
      // 抽屉其他内容
    ],
  );
}

Widget showComScale(BuildContext context, int selScaleId) {
  return ListTile(
    selected: selScaleId == myComScaleInfo.scaleId,
    dense: true,
    title: Tooltip(
      richMessage: TextSpan(
        text: '${myComScaleInfo.portName}\r\n\r\n',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        children: <InlineSpan>[
          TextSpan(
            text:
                'Model:${myComScaleInfo.scaleModel == "TMax" ? "" : myComScaleInfo.scaleModel}\r\nSN:${myComScaleInfo.scaleModel == "TMax" ? "" : myComScaleInfo.scaleSn}\r\nPort:${myComScaleInfo.baudRate}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      child: Text(
        myComScaleInfo.scaleName,
        maxLines: 1, // 设置文本最大行数为1
        style: const TextStyle(
          fontSize: 16,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    subtitle: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: 100,
            child: Text(
              myComScaleInfo.isOnline
                  ? localizedStrings.gOnlineTip
                  : localizedStrings.gOfflineTip,
              maxLines: 1, // 设置文本最大行数为1
              style: TextStyle(
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
                color: myComScaleInfo.isOnline
                    ? Theme.of(context).colorScheme.surfaceContainerHigh
                    : Theme.of(context).colorScheme.error,
              ),
            )),
        Icon(Icons.cable),
      ],
    ),
    trailing: Tooltip(
      message: '', // localizedStrings.rJoinManagementTip,
      child: IconButton(
          onPressed: () {
            selScaleId = 1;
            eventBus.fire(EventSelWeighingScaleId(selScaleId));
          },
          icon: Icon(
            selScaleId == 1 ? Icons.check_box : Icons.check_box_outline_blank,
            color: Theme.of(context).colorScheme.primary,
          )),
    ),
    onTap: () {},
  );
}

Widget showNetScaleList(List<NetScaleInfoLocal> scaleNetItems, int selScaleId) {
  return Expanded(
    child: ListView.builder(
      itemCount: scaleNetItems.length,
      itemBuilder: (context, index) {
        return SizedBox(
          child: Column(
            children: [
              ListTile(
                selected: selScaleId == scaleNetItems[index].scaleId,
                dense: true,
                title: Tooltip(
                  richMessage: TextSpan(
                    text: '${scaleNetItems[index].ip!}\r\n\r\n',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    children: <InlineSpan>[
                      TextSpan(
                        text:
                            'Model:${scaleNetItems[index].scaleModel! == "TMax" ? "" : scaleNetItems[index].scaleModel!}\r\nSN:${scaleNetItems[index].scaleModel! == "TMax" ? "" : scaleNetItems[index].scaleSn!}\r\nPort:${scaleNetItems[index].port!}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  child: Text(
                    scaleNetItems[index].scaleName!,
                    maxLines: 1, // 设置文本最大行数为1
                    style: const TextStyle(
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        scaleNetItems[index].isOnline!
                            ? localizedStrings.gOnlineTip
                            : localizedStrings.gOfflineTip,
                        maxLines: 1, // 设置文本最大行数为1
                        style: TextStyle(
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          color: scaleNetItems[index].isOnline!
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    const Icon(Icons.wifi)
                  ],
                ),
                // selectedTileColor: Theme.of(context).colorScheme.primary,
                trailing: Tooltip(
                  message: '', // localizedStrings.rJoinManagementTip,
                  child: IconButton(
                      onPressed: () {
                        selScaleId = scaleNetItems[index].scaleId!;
                        eventBus.fire(EventSelWeighingScaleId(selScaleId));
                      },
                      icon: Icon(
                        selScaleId == scaleNetItems[index].scaleId
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                ),
                onTap: () {},
              )
            ],
          ),
        );
      },
    ),
  );
}
