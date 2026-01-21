// To parse this JSON data, do
//
//     final sealLogInfo = sealLogInfoFromJson(jsonString);

import 'dart:convert';

List<SealLogInfo> sealLogInfoFromJson(String str) => List<SealLogInfo>.from(
    json.decode(str).map((x) => SealLogInfo.fromJson(x)));

String sealLogInfoToJson(List<SealLogInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SealLogInfo {
  int? recId;
  String? model;
  int? scaleId;
  String? sn;
  int? roleId;
  String? operator;
  String? operation;
  DateTime? operationTime;
  String? remark;
  String? result;

  SealLogInfo({
    this.recId,
    this.model,
    this.scaleId,
    this.sn,
    this.roleId,
    this.operator,
    this.operation,
    this.operationTime,
    this.remark,
    this.result,
  });

  factory SealLogInfo.fromJson(Map<String, dynamic> json) => SealLogInfo(
        recId: json["RecId"],
        model: json["Model"],
        scaleId: json["ScaleId"],
        sn: json["Sn"],
        roleId: json["RoleId"],
        operator: json["Operator"],
        operation: json["Operation"],
        operationTime: json["OperationTime"] == null
            ? null
            : DateTime.parse(json["OperationTime"]).toLocal(),
        remark: json["Remark"],
        result: json["Result"],
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "Model": model,
        "ScaleId": scaleId,
        "Sn": sn,
        "RoleId": roleId,
        "Operator": operator,
        "Operation": operation,
        "OperationTime": operationTime?.toIso8601String(),
        "Remark": remark,
        "Result": result,
      };
}
