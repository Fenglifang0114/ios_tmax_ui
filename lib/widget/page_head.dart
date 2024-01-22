import 'package:flutter/material.dart';
import 'package:t_max/data/timer_manager.dart';
import '../data/screen_mgr.dart';
import '../functions/methods.dart';
import 'box_gradient.dart';
import 'custom_circle_icon.dart';

Widget pageHead(
  dynamic context,
  String pageTitle,
  String serialPortStatus,
) {
  return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Container(
        decoration: BoxDecoration(gradient: boxGradient()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: SizedBox(
                  width: 400,
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
                                        myScreenMgr.isMainScreen = true;
                                        cntScaleTimerMgr.stopCntScaleTimer();
                                        PublicFunctions.stopWeight();
                                        Navigator.of(context).pop();
                                      },
                                      icon: CustomCircleIcon(
                                        outerColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        innerColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
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
                      ? const CustomCircleIcon(
                          outerColor: Colors.blue,
                          innerColor: Colors.white,
                          icon: Icons.check_circle,
                          size: 24.0,
                        )
                      : const CustomCircleIcon(
                          outerColor: Colors.red,
                          innerColor: Colors.white,
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
