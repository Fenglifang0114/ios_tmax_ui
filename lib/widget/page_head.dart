import 'package:flutter/material.dart';
import 'package:t_max/data/timer_manager.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import '../functions/methods.dart';
import 'box_gradient.dart';
import 'custom_button.dart';
import 'custom_circle_icon.dart';

Widget pageHead(
  dynamic context,
  String pageTitle,
  String serialPortStatus,
) {
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
                                    _showConfirmationDialog(context);
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
                  (myScreenMgr.serialPortST)
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

void _showConfirmationDialog(BuildContext context) {
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
      PublicFunctions.closeScalePassth();
      PublicFunctions.stopWeight();
      Navigator.of(context).pop();
    }
  });
}

Widget pageHeadDesign(dynamic context, String pageTitle) {
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
                                    _showConfirmationDialog(context);
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
