// To parse this JSON data, do
//
//     final flowRateFromDb = flowRateFromDbFromJson(jsonString);

import 'dart:convert';

List<FlowRateFromDb> flowRateFromDbFromJson(String str) =>
    List<FlowRateFromDb>.from(
        json.decode(str).map((x) => FlowRateFromDb.fromJson(x)));

String flowRateFromDbToJson(List<FlowRateFromDb> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FlowRateFromDb {
  FlowRateHeader? flowRateHeader;
  List<FlowRateDetail>? flowRateDetail;

  FlowRateFromDb({
    this.flowRateHeader,
    this.flowRateDetail,
  });

  factory FlowRateFromDb.fromJson(Map<String, dynamic> json) => FlowRateFromDb(
        flowRateHeader: json["FlowRateHeader"] == null
            ? null
            : FlowRateHeader.fromJson(json["FlowRateHeader"]),
        flowRateDetail: json["FlowRateDetail"] == null
            ? []
            : List<FlowRateDetail>.from(
                json["FlowRateDetail"]!.map((x) => FlowRateDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "FlowRateHeader": flowRateHeader?.toJson(),
        "FlowRateDetail": flowRateDetail == null
            ? []
            : List<dynamic>.from(flowRateDetail!.map((x) => x.toJson())),
      };
}

class FlowRateDetail {
  int? recId;
  int? headerId;
  int? id;
  double? rate;
  double? time;

  FlowRateDetail({
    this.recId,
    this.headerId,
    this.id,
    this.rate,
    this.time,
  });

  factory FlowRateDetail.fromJson(Map<String, dynamic> json) => FlowRateDetail(
        recId: json["RecId"],
        headerId: json["HeaderId"],
        id: json["Id"],
        rate: json["Rate"]?.toDouble(),
        time: json["Time"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "HeaderId": headerId,
        "Id": id,
        "Rate": rate,
        "Time": time,
      };
}

class FlowRateHeader {
  int? recId;
  double? totalWeight;
  double? totalTime;
  double? averageFlowRate;
  double? minFlowRate;
  double? maxFlowRate;
  String? wgtUnit;
  DateTime? createdAt;

  FlowRateHeader({
    this.recId,
    this.totalWeight,
    this.totalTime,
    this.averageFlowRate,
    this.minFlowRate,
    this.maxFlowRate,
    this.wgtUnit,
    this.createdAt,
  });

  factory FlowRateHeader.fromJson(Map<String, dynamic> json) => FlowRateHeader(
        recId: json["RecId"],
        totalWeight: json["TotalWeight"]?.toDouble(),
        totalTime: json["TotalTime"]?.toDouble(),
        averageFlowRate: json["AverageFlowRate"]?.toDouble(),
        minFlowRate: json["MinFlowRate"]?.toDouble(),
        maxFlowRate: json["MaxFlowRate"]?.toDouble(),
        wgtUnit: json["WgtUnit"],
        createdAt: json["CreatedAt"] == null
            ? null
            : DateTime.parse(json["CreatedAt"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "TotalWeight": totalWeight,
        "TotalTime": totalTime,
        "AverageFlowRate": averageFlowRate,
        "MinFlowRate": minFlowRate,
        "MaxFlowRate": maxFlowRate,
        "WgtUnit": wgtUnit,
        "CreatedAt": createdAt?.toIso8601String(),
      };
}
