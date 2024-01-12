import 'package:flutter/material.dart';
import 'box_gradient.dart';
import 'custom_circle_icon.dart';

Widget pageHead(dynamic context, String pageTitle) {
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
          ],
        ),
      ));
}
