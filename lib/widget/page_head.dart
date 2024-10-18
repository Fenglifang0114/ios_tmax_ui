import 'package:flutter/material.dart';
import '../data/comscaleinfo_data.dart';
import '../data/manager_scale_channel.dart';
import 'package:t_max/data/timer_manager.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import '../functions/methods.dart';
import 'box_gradient.dart';
import 'custom_button.dart';
import 'custom_circle_icon.dart';

Widget pageHead(dynamic context, String pageTitle, String serialPortStatus,
    List<int> scaleList) {
  return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Container(
        decoration: BoxDecoration(gradient: boxGradient(context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: SizedBox(
                  child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                      // width: _width,
                      height: 50,
                      alignment: Alignment.centerLeft, //设置控件内容的位置
                      child: Row(
                        children: [
                          SizedBox(
                              width: 50,
                              height: 50,
                              child: IconButton(
                                  onPressed: () {
                                    _showConfirmationDialog(context, scaleList);
                                  },
                                  icon: CustomCircleIcon(
                                    outerColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    innerColor:
                                        Theme.of(context).colorScheme.primary,
                                    icon: Icons.home,
                                    size: 30.0,
                                  ))),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            child: Text(
                              pageTitle,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )),
                ],
              )),
            ),
            SizedBox(
              width: 360,
              height: 50,
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Text(serialPortStatus,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  (myComScaleInfo.isOnline)
                      ? CustomCircleIcon(
                          outerColor: Theme.of(context).colorScheme.primary,
                          innerColor: Theme.of(context).colorScheme.onPrimary,
                          icon: Icons.check_circle,
                          size: 24.0,
                        )
                      : CustomCircleIcon(
                          outerColor: Theme.of(context).colorScheme.error,
                          innerColor: Theme.of(context).colorScheme.onPrimary,
                          icon: Icons.cancel,
                          size: 24.0,
                        ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ));
}

void _showConfirmationDialog(BuildContext context, List<int> scaleList) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(
          'Confirmation',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Text(localizedStrings.go_home),
        actions: <Widget>[
          Row(
            children: [
              CustomElevatedButton(
                btnWidth: 100,
                btnHeight: 40,
                icon: Icons.check_circle,
                text: localizedStrings.confirm_btn,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              const SizedBox(width: 20),
              CustomOutlinedButton(
                btnWidth: 100,
                btnHeight: 40,
                icon: Icons.cancel,
                text: localizedStrings.button_cancel,
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          )
        ],
      );
    },
  ).then((confirmed) {
    if (confirmed) {
      myScreenMgr.isMainScreen = true;
      cntScaleTimerMgr.stopCntScaleTimer();
      PublicFunctions.closewifiPassth(1);
      if (scaleList.isNotEmpty) {
        for (int i = 0; i < scaleList.length; i++) {
          PublicFunctions.stopWeight(scaleList[i]);
        }
      }
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  });
}

Widget pageHeadDesign(dynamic context, String pageTitle, List<int> scaleList) {
  return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Container(
        decoration: BoxDecoration(gradient: boxGradient(context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: SizedBox(
                  child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                      // width: _width,
                      height: 50,
                      alignment: Alignment.centerLeft, //设置控件内容的位置
                      child: Row(
                        children: [
                          SizedBox(
                              width: 50,
                              height: 50,
                              child: IconButton(
                                  onPressed: () {
                                    _showConfirmationDialog(context, scaleList);
                                  },
                                  icon: CustomCircleIcon(
                                    outerColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    innerColor:
                                        Theme.of(context).colorScheme.primary,
                                    icon: Icons.home,
                                    size: 30.0,
                                  ))),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            child: Text(
                              pageTitle,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )),
                ],
              )),
            ),
          ],
        ),
      ));
}

Widget pageHeadDefScale(dynamic context, String pageTitle) {
  List<int> scaleList = [myDefScaleInfo.defScaleId!];
  return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Container(
        decoration: BoxDecoration(gradient: boxGradient(context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: SizedBox(
                  child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                      // width: _width,
                      height: 50,
                      alignment: Alignment.centerLeft, //设置控件内容的位置
                      child: Row(
                        children: [
                          SizedBox(
                              width: 50,
                              height: 50,
                              child: IconButton(
                                  onPressed: () {
                                    _showConfirmationDialog(context, scaleList);
                                  },
                                  icon: CustomCircleIcon(
                                    outerColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    innerColor:
                                        Theme.of(context).colorScheme.primary,
                                    icon: Icons.home,
                                    size: 30.0,
                                  ))),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            child: Text(
                              pageTitle,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )),
                ],
              )),
            ),
            SizedBox(
              width: 360,
              height: 50,
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Tooltip(
                        message: myDefScaleInfo.defScaleId == 1
                            ? '${myDefScaleInfo.defScaleModel!}\r\nSN:${myDefScaleInfo.defScaleSn!}\r\nSerial Port:${myDefScaleInfo.defScalePort!}\r\nBuadRate:${myDefScaleInfo.defScaleBaud!}'
                            : '${myDefScaleInfo.defScaleModel!}\r\nSN:${myDefScaleInfo.defScaleSn!}\r\nIP:${myDefScaleInfo.defScaleIp!}\r\nPort:${myDefScaleInfo.defScalePort!}',
                        child: Text(myDefScaleInfo.defScaleName!,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                    Theme.of(context).colorScheme.onPrimary))),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ));
}
