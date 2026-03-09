// To parse this JSON data, do
//
//     final reqPortInfo = reqPortInfoFromJson(jsonString);

import 'dart:convert';

ReqPortInfo reqPortInfoFromJson(String str) =>
    ReqPortInfo.fromJson(json.decode(str));

String reqPortInfoToJson(ReqPortInfo data) => json.encode(data.toJson());

class ReqPortInfo {
  int? portId;
  bool? status;

  ReqPortInfo({
    this.portId,
    this.status,
  });

  factory ReqPortInfo.fromJson(Map<String, dynamic> json) => ReqPortInfo(
        portId: json["PortId"],
        status: json["Status"],
      );

  Map<String, dynamic> toJson() => {
        "PortId": portId,
        "Status": status,
      };
}

ReqGetOutput reqGetOutputFromJson(String str) =>
    ReqGetOutput.fromJson(json.decode(str));

String reqGetOutputToJson(ReqGetOutput data) => json.encode(data.toJson());

String reqOutputToJson(List<ReqGetOutput> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReqGetOutput {
  int? port;
  bool? status;
  int? startTime;
  double? endValue;
  String? remark;

  ReqGetOutput({
    this.port,
    this.status,
    this.startTime,
    this.endValue,
    this.remark,
  });

  factory ReqGetOutput.fromJson(Map<String, dynamic> json) => ReqGetOutput(
        port: json["Port"],
        status: json["Status"],
        startTime: json["StartTime"],
        endValue: json["EndValue"],
        remark: json["Remark"],
      );

  Map<String, dynamic> toJson() => {
        "Port": port,
        "Status": status,
        "StartTime": startTime,
        "EndValue": endValue,
        "Remark": remark,
      };
}

// To parse this JSON data, do
//
//     final respOutputInfo = respOutputInfoFromJson(jsonString);

List<RespOutputInfo> respOutputInfoFromJson(String str) =>
    List<RespOutputInfo>.from(
        json.decode(str).map((x) => RespOutputInfo.fromJson(x)));

String respOutputInfoToJson(List<RespOutputInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RespOutputInfo {
  int? recId;
  int? port;
  bool? status;
  int? startTime;
  double? endValue;
  String? remark;

  RespOutputInfo({
    this.recId,
    this.port,
    this.status,
    this.startTime,
    this.endValue,
    this.remark,
  });

  factory RespOutputInfo.fromJson(Map<String, dynamic> json) => RespOutputInfo(
        recId: json["RecID"],
        port: json["Port"],
        status: json["Status"],
        startTime: json["StartTime"],
        endValue: json["EndValue"]?.toDouble(),
        remark: json["Remark"],
      );

  Map<String, dynamic> toJson() => {
        "RecID": recId,
        "Port": port,
        "Status": status,
        "StartTime": startTime,
        "EndValue": endValue,
        "Remark": remark,
      };
}

class CurrentPortSetting {
  bool isEnable; //是否启用
  bool isOpen; //是否打开输出端口
  int portNo; //端口号
  double triggerValue; //触发值
  int delayedTime; //延时时间

  CurrentPortSetting(
      {required this.isEnable,
      required this.isOpen,
      required this.portNo,
      required this.triggerValue,
      required this.delayedTime});
}
