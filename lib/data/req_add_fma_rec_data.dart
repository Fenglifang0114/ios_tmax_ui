// To parse this JSON data, do
//
//     final reqAddFmaRec = reqAddFmaRecFromJson(jsonString);

import 'dart:convert';

ReqAddFmaRec reqAddFmaRecFromJson(String str) =>
    ReqAddFmaRec.fromJson(json.decode(str));

String reqAddFmaRecToJson(ReqAddFmaRec data) => json.encode(data.toJson());

class ReqAddFmaRec {
  RecHeader? recHeader;
  List<RecDetail>? recDetail;

  ReqAddFmaRec({
    this.recHeader,
    this.recDetail,
  });

  factory ReqAddFmaRec.fromJson(Map<String, dynamic> json) => ReqAddFmaRec(
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
  int? recId;
  String? recordId;
  String? materialId;
  String? materialTypeId;
  String? materialTypeName;
  int? sequence;
  double? allowableError;
  double? targetWgt;
  double? actualWeight;
  String? actualWeightUnit;
  double? actualPercentage;
  double? actualErrorWgt;
  double? actualErrorPct;
  String? isQualified;

  RecDetail({
    this.recId,
    this.recordId,
    this.materialId,
    this.materialTypeId,
    this.materialTypeName,
    this.sequence,
    this.allowableError,
    this.targetWgt,
    this.actualWeight,
    this.actualWeightUnit,
    this.actualPercentage,
    this.actualErrorWgt,
    this.actualErrorPct,
    this.isQualified,
  });

  factory RecDetail.fromJson(Map<String, dynamic> json) => RecDetail(
        recId: json["RecId"],
        recordId: json["RecordID"],
        materialId: json["MaterialID"],
        materialTypeId: json["MaterialTypeId"],
        materialTypeName: json["MaterialTypeName"],
        sequence: json["Sequence"],
        allowableError: json["AllowableError"],
        targetWgt: json["TargetWgt"],
        actualWeight: json["ActualWeight"],
        actualWeightUnit: json["ActualWeightUnit"],
        actualPercentage: json["ActualPercentage"]?.toDouble(),
        actualErrorWgt: json["ActualErrorWgt"],
        actualErrorPct: json["ActualErrorPct"],
        isQualified: json["IsQualified"],
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "RecordID": recordId,
        "MaterialID": materialId,
        "MaterialTypeId": materialTypeId,
        "MaterialTypeName": materialTypeName,
        "Sequence": sequence,
        "AllowableError": allowableError,
        "TargetWgt": targetWgt,
        "ActualWeight": actualWeight,
        "ActualWeightUnit": actualWeightUnit,
        "ActualPercentage": actualPercentage,
        "ActualErrorWgt": actualErrorWgt,
        "ActualErrorPct": actualErrorPct,
        "IsQualified": isQualified,
      };
}

class RecHeader {
  String? recordId;
  String? recHeaderOperator;
  String? formulaId;
  String? formulaTypeName;
  double? totalWeight;
  double? actualTotalWeight;
  String? totalWeightUnit;
  String? totalMaterialWeightUnit;
  String? isQualified;
  double? actualFmaTotalWgt;
  int? scaleId;
  String? scaleName;
  String? scaleModel;
  String? scaleSn;

  RecHeader({
    this.recordId,
    this.recHeaderOperator,
    this.formulaId,
    this.formulaTypeName,
    this.totalWeight,
    this.actualTotalWeight,
    this.totalWeightUnit,
    this.totalMaterialWeightUnit,
    this.isQualified,
    this.actualFmaTotalWgt,
    this.scaleId,
    this.scaleName,
    this.scaleModel,
    this.scaleSn,
  });

  factory RecHeader.fromJson(Map<String, dynamic> json) => RecHeader(
        recordId: json["RecordID"],
        recHeaderOperator: json["Operator"],
        formulaId: json["FormulaID"],
        formulaTypeName: json["FormulaTypeName"],
        totalWeight: json["TotalWeight"],
        actualTotalWeight: json["ActualTotalWeight"]?.toDouble(),
        totalWeightUnit: json["TotalWeightUnit"],
        totalMaterialWeightUnit: json["TotalMaterialWeightUnit"],
        isQualified: json["IsQualified"],
        actualFmaTotalWgt: json["ActualFmaTotalWgt"],
        scaleId: json["ScaleId"],
        scaleName: json["ScaleName"],
        scaleModel: json["ScaleModel"],
        scaleSn: json["ScaleSn"],
      );

  Map<String, dynamic> toJson() => {
        "RecordID": recordId,
        "Operator": recHeaderOperator,
        "FormulaID": formulaId,
        "FormulaTypeName": formulaTypeName,
        "TotalWeight": totalWeight,
        "ActualTotalWeight": actualTotalWeight,
        "TotalWeightUnit": totalWeightUnit,
        "TotalMaterialWeightUnit": totalMaterialWeightUnit,
        "IsQualified": isQualified,
        "ActualFmaTotalWgt": actualFmaTotalWgt,
        "ScaleId": scaleId,
        "ScaleName": scaleName,
        "ScaleModel": scaleModel,
        "ScaleSn": scaleSn,
      };
}
