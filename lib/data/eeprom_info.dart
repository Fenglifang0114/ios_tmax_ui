import 'dart:convert';

class EepromInfo {
  String? filedName;
  int? size;
  int? addr;
  String? type;
  String? subType;
  int? permission;
  String? values;
  String? currValue;
  String? oldValue;
  String? description;
  String? comment;
  String? category;
  bool? isChanged;

  EepromInfo(
      {this.filedName,
      this.size,
      this.addr,
      this.type,
      this.subType,
      this.permission,
      this.values,
      this.currValue,
      this.oldValue,
      this.description,
      this.comment,
      this.category,
      this.isChanged});

  factory EepromInfo.fromRawJson(String str) =>
      EepromInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EepromInfo.fromJson(Map<String, dynamic> json) => EepromInfo(
        filedName: json["filedName"],
        size: json["size"],
        addr: json["addr"],
        type: json["type"],
        subType: json["subType"],
        permission: json["permission"],
        values: json["values"],
        currValue: json["currValue"],
        description: json["description"],
        comment: json["comment"],
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "filedName": filedName,
        "size": size,
        "addr": addr,
        "type": type,
        "subType": subType,
        "permission": permission,
        "values": values,
        "currValue": currValue,
        "description": description,
        "comment": comment,
        "category": category,
      };
}

EepromInfo myEepromInfo = EepromInfo();
