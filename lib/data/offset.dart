import 'package:flutter/material.dart';

class OffsetData {
  double x;
  double y;
  double width;
  double height;
  Key key;
  OffsetData(this.x, this.y, this.width, this.height, this.key);
  OffsetData.fromJson(Map<String, dynamic> json)
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

OffsetData myOffsetData = OffsetData(0.0, 0.0, 0, 0, const ObjectKey(0));

class OffsetDataList {
  List<OffsetData> offsetDataList;
  OffsetDataList(this.offsetDataList);
}

OffsetDataList myOffsetDataList = OffsetDataList([]);
