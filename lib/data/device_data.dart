import 'package:flutter/material.dart';

class Devicedata {
  String name;
  String type;
  List<Color> color;
  String index;
  String scaleID;
  String scaleSn;
  int mediaType;
  Devicedata(this.name, this.type, this.color, this.index, this.scaleID,
      this.scaleSn, this.mediaType);
  Devicedata.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        type = json['type'],
        color = json['color'],
        scaleID = json['scaleID'],
        index = json['index'],
        scaleSn = json['scaleSn'],
        mediaType = json['mediaType'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'color': color,
      'index': index,
      'scaleID': scaleID,
      'scaleSn': scaleSn,
      'mediaType': mediaType,
    };
  }
}

Devicedata myDevicedata = Devicedata("", "", [], "", "", "", 0);
