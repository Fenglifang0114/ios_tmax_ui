// To parse this JSON data, do
//
//     final reqFlowRate = reqFlowRateFromJson(jsonString);

import 'dart:convert';

ReqFlowRate reqFlowRateFromJson(String str) =>
    ReqFlowRate.fromJson(json.decode(str));

String reqFlowRateToJson(ReqFlowRate data) => json.encode(data.toJson());

class ReqFlowRate {
  RecHeader? recHeader;
  List<RecDetail>? recDetail;

  ReqFlowRate({
    this.recHeader,
    this.recDetail,
  });

  factory ReqFlowRate.fromJson(Map<String, dynamic> json) => ReqFlowRate(
        recHeader: json["RecHeader"] == null
            ? null
            : RecHeader.fromJson(json["RecHeader"]),
        recDetail: json["RecDetail"] == null
            ? []
            : List<RecDetail>.from(
                json["RecDetail"]!.map((x) => RecDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "RecHeader": recHeader?.toJson(),
        "RecDetail": recDetail == null
            ? []
            : List<dynamic>.from(recDetail!.map((x) => x.toJson())),
      };
}

class RecDetail {
  int? id;
  double? rate;
  double? time;

  RecDetail({
    this.id,
    this.rate,
    this.time,
  });

  factory RecDetail.fromJson(Map<String, dynamic> json) => RecDetail(
        id: json["Id"],
        rate: json["Rate"]?.toDouble(),
        time: json["Time"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Rate": rate,
        "Time": time,
      };
}

class RecHeader {
  double? totalWeight;
  double? totalTime;
  double? averageFlowRate;
  double? minFlowRate;
  double? maxFlowRate;
  String? wgtUnit;

  RecHeader({
    this.totalWeight,
    this.totalTime,
    this.averageFlowRate,
    this.minFlowRate,
    this.maxFlowRate,
    this.wgtUnit,
  });

  factory RecHeader.fromJson(Map<String, dynamic> json) => RecHeader(
        totalWeight: json["TotalWeight"]?.toDouble(),
        totalTime: json["TotalTime"]?.toDouble(),
        averageFlowRate: json["AverageFlowRate"]?.toDouble(),
        minFlowRate: json["MinFlowRate"]?.toDouble(),
        maxFlowRate: json["MaxFlowRate"]?.toDouble(),
        wgtUnit: json["WgtUnit"],
      );

  Map<String, dynamic> toJson() => {
        "TotalWeight": totalWeight,
        "TotalTime": totalTime,
        "AverageFlowRate": averageFlowRate,
        "MinFlowRate": minFlowRate,
        "MaxFlowRate": maxFlowRate,
        "WgtUnit": wgtUnit,
      };
}
