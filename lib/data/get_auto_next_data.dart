// To parse this JSON data, do
//
//     final getAutoNextFormDb = getAutoNextFormDbFromJson(jsonString);

//配方中的自动下一步

import 'dart:convert';

GetAutoNextFormDb getAutoNextFormDbFromJson(String str) =>
    GetAutoNextFormDb.fromJson(json.decode(str));

String getAutoNextFormDbToJson(GetAutoNextFormDb data) =>
    json.encode(data.toJson());

class GetAutoNextFormDb {
  int recId;
  bool autoNext;
  int stableTime;
  bool autoTare;
  bool checkCode;

  GetAutoNextFormDb({
    required this.recId,
    required this.autoNext,
    required this.stableTime,
    required this.autoTare,
    required this.checkCode,
  });

  factory GetAutoNextFormDb.fromJson(Map<String, dynamic> json) =>
      GetAutoNextFormDb(
        recId: json["RecID"],
        autoNext: json["AutoNext"],
        stableTime: json["StableTime"],
        autoTare: json["AutoTare"],
        checkCode: json["CheckCode"],
      );

  Map<String, dynamic> toJson() => {
        "RecID": recId,
        "AutoNext": autoNext,
        "StableTime": stableTime,
        "AutoTare": autoTare,
        "CheckCode": checkCode,
      };
}

String reqAutoNextToJson(ReqAutoNext data) => json.encode(data.toJson());

class ReqAutoNext {
  bool autoNext;
  int stableTime;
  bool autoTare;
  bool checkCode;

  ReqAutoNext(
      {required this.autoNext,
      required this.stableTime,
      required this.autoTare,
      required this.checkCode});

  factory ReqAutoNext.fromJson(Map<String, dynamic> json) => ReqAutoNext(
      autoNext: json["AutoNext"],
      stableTime: json["StableTime"],
      autoTare: json["AutoTare"],
      checkCode: json["CheckCode"]);

  Map<String, dynamic> toJson() => {
        "AutoNext": autoNext,
        "StableTime": stableTime,
        "AutoTare": autoTare,
        "CheckCode": checkCode,
      };
}
