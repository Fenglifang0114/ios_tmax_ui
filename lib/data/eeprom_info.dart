import 'dart:convert';

class EepromInfo {
  String? filedName;
  int? size;
  int? addr;
  String? type;
  int? permission;
  String? values;
  String? currValue;
  String? description;
  String? comment;

  EepromInfo({
    this.filedName,
    this.size,
    this.addr,
    this.type,
    this.permission,
    this.values,
    this.currValue,
    this.description,
    this.comment,
  });

  factory EepromInfo.fromRawJson(String str) =>
      EepromInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EepromInfo.fromJson(Map<String, dynamic> json) => EepromInfo(
        filedName: json["filedName"],
        size: json["size"],
        addr: json["addr"],
        type: json["type"],
        permission: json["permission"],
        values: json["values"],
        currValue: json["currValue"],
        description: json["description"],
        comment: json["Comment"],
      );

  Map<String, dynamic> toJson() => {
        "filedName": filedName,
        "size": size,
        "addr": addr,
        "type": type,
        "permission": permission,
        "values": values,
        "currValue": currValue,
        "description": description,
        "Comment": comment,
      };
}

EepromInfo myEepromInfo = EepromInfo();
