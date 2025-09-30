// To parse this JSON data, do
//
//     final formulaInfoDb = formulaInfoDbFromJson(jsonString);

import 'dart:convert';

List<FormulaInfoDb> formulaInfoDbFromJson(String str) =>
    List<FormulaInfoDb>.from(
        json.decode(str).map((x) => FormulaInfoDb.fromJson(x)));

String formulaInfoDbToJson(List<FormulaInfoDb> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FormulaInfoDb {
  Header? header;
  List<Detail>? details;

  FormulaInfoDb({
    this.header,
    this.details,
  });

  factory FormulaInfoDb.fromJson(Map<String, dynamic> json) => FormulaInfoDb(
        header: json["Header"] == null ? null : Header.fromJson(json["Header"]),
        details: json["Details"] == null
            ? []
            : List<Detail>.from(
                json["Details"]!.map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Header": header?.toJson(),
        "Details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class Detail {
  int? recId;
  int? formulaRecId;
  String? materialId;
  double? materialWeight;
  double? materialPercentage;
  int? sequence;
  double? allowableError;
  String? remark;
  String? remark1;

  Detail({
    this.recId,
    this.formulaRecId,
    this.materialId,
    this.materialWeight,
    this.materialPercentage,
    this.sequence,
    this.allowableError,
    this.remark,
    this.remark1,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        recId: json["RecId"],
        formulaRecId: json["FormulaRecID"],
        materialId: json["MaterialID"],
        materialWeight: json["MaterialWeight"]?.toDouble(),
        materialPercentage: json["MaterialPercentage"]?.toDouble(),
        sequence: json["Sequence"],
        allowableError: json["AllowableError"]?.toDouble(),
        remark: json["Remark"],
        remark1: json["Remark1"],
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "FormulaRecID": formulaRecId,
        "MaterialID": materialId,
        "MaterialWeight": materialWeight,
        "MaterialPercentage": materialPercentage,
        "Sequence": sequence,
        "AllowableError": allowableError,
        "Remark": remark,
        "Remark1": remark1,
      };
}

class Header {
  int? recId;
  int? formulaKey;
  String? formulaId;
  String? formulaName;
  int? categoryId;
  String? formulaMode;
  String? formulaUnit;
  double? totalWeight;
  int? materialCount;
  bool? isEncrypted;
  bool? needContainer;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? createdBy;
  String? updatedBy;
  String? remark;
  String? remark1;
  String? remark2;
  String? remark3;
  bool? isUsed;
  bool? isLatest;

  Header({
    this.recId,
    this.formulaKey,
    this.formulaId,
    this.formulaName,
    this.categoryId,
    this.formulaMode,
    this.formulaUnit,
    this.totalWeight,
    this.materialCount,
    this.isEncrypted,
    this.needContainer,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.remark,
    this.remark1,
    this.remark2,
    this.remark3,
    this.isUsed,
    this.isLatest,
  });

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        recId: json["RecId"],
        formulaKey: json["FormulaKey"],
        formulaId: json["FormulaID"],
        formulaName: json["FormulaName"],
        categoryId: json["CategoryID"],
        formulaMode: json["FormulaMode"],
        formulaUnit: json["FormulaUnit"],
        totalWeight: json["TotalWeight"]?.toDouble(),
        materialCount: json["MaterialCount"],
        isEncrypted: json["IsEncrypted"],
        needContainer: json["NeedContainer"],
        createdAt: json["CreatedAt"] == null
            ? null
            : DateTime.parse(json["CreatedAt"]).toLocal(),
        updatedAt: json["UpdatedAt"] == null
            ? null
            : DateTime.parse(json["UpdatedAt"]).toLocal(),
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        remark: json["Remark"],
        remark1: json["Remark1"],
        remark2: json["Remark2"],
        remark3: json["Remark3"],
        isUsed: json["IsUsed"],
        isLatest: json["IsLatest"],
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "FormulaKey": formulaKey,
        "FormulaID": formulaId,
        "FormulaName": formulaName,
        "CategoryID": categoryId,
        "FormulaMode": formulaMode,
        "FormulaUnit": formulaUnit,
        "TotalWeight": totalWeight,
        "MaterialCount": materialCount,
        "IsEncrypted": isEncrypted,
        "NeedContainer": needContainer,
        "CreatedAt": createdAt?.toIso8601String(),
        "UpdatedAt": updatedAt?.toIso8601String(),
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "Remark": remark,
        "Remark1": remark1,
        "Remark2": remark2,
        "Remark3": remark3,
        "IsUsed": isUsed,
        "IsLatest": isLatest,
      };
}
