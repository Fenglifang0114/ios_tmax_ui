import 'package:flutter/material.dart';

class ReceiptOffsetData {
  double x;
  double y;
  double width;
  double height;
  Key key;
  ReceiptOffsetData(this.x, this.y, this.width, this.height, this.key);
  ReceiptOffsetData.fromJson(Map<String, dynamic> json)
      : x = json['x'],
        width = json['width'],
        height = json['height'],
        key = json['key'],
        y = json['y'];

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'key': key,
    };
  }
}

ReceiptOffsetData myReceiptOffsetData =
    ReceiptOffsetData(0.0, 0.0, 0, 0, const ObjectKey(0));

class ReceiptOffsetDataList {
  List<ReceiptOffsetData> offsetDataList;
  ReceiptOffsetDataList(this.offsetDataList);
}

ReceiptOffsetDataList myReceiptOffsetDataList = ReceiptOffsetDataList([]);
