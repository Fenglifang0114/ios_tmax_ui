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
  FormulaDetail? formulaDetail;
  RawMaterialTypeName? rawMaterialTypeName;

  Detail({
    this.formulaDetail,
    this.rawMaterialTypeName,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        formulaDetail: json["FormulaDetail"] == null
            ? null
            : FormulaDetail.fromJson(json["FormulaDetail"]),
        rawMaterialTypeName: json["RawMaterialTypeName"] == null
            ? null
            : RawMaterialTypeName.fromJson(json["RawMaterialTypeName"]),
      );

  Map<String, dynamic> toJson() => {
        "FormulaDetail": formulaDetail?.toJson(),
        "RawMaterialTypeName": rawMaterialTypeName?.toJson(),
      };
}

class FormulaDetail {
  int? recId;
  String? formulaId;
  String? materialId;
  double? materialWeight;
  double? materialPercentage;
  int? sequence;
  double? allowableError;
  String? remark;
  String? remark1;

  FormulaDetail({
    this.recId,
    this.formulaId,
    this.materialId,
    this.materialWeight,
    this.materialPercentage,
    this.sequence,
    this.allowableError,
    this.remark,
    this.remark1,
  });

  factory FormulaDetail.fromJson(Map<String, dynamic> json) => FormulaDetail(
        recId: json["RecId"],
        formulaId: json["FormulaID"],
        materialId: json["MaterialID"],
        materialWeight: (json["MaterialWeight"] as num?)?.toDouble(),
        materialPercentage: (json["MaterialPercentage"] as num?)?.toDouble(),
        sequence: json["Sequence"],
        allowableError: (json["AllowableError"] as num?)?.toDouble(),
        remark: json["Remark"],
        remark1: json["Remark1"],
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "FormulaID": formulaId,
        "MaterialID": materialId,
        "MaterialWeight": materialWeight,
        "MaterialPercentage": materialPercentage,
        "Sequence": sequence,
        "AllowableError": allowableError,
        "Remark": remark,
        "Remark1": remark1,
      };
}

class RawMaterialTypeName {
  RawMaterialDb? rawMaterial;
  String? rawCategoryName;

  RawMaterialTypeName({
    this.rawMaterial,
    this.rawCategoryName,
  });

  factory RawMaterialTypeName.fromJson(Map<String, dynamic> json) =>
      RawMaterialTypeName(
        rawMaterial: json["rawMaterial"] == null
            ? null
            : RawMaterialDb.fromJson(json["rawMaterial"]),
        rawCategoryName: json["rawCategoryName"],
      );

  Map<String, dynamic> toJson() => {
        "rawMaterial": rawMaterial?.toJson(),
        "rawCategoryName": rawCategoryName,
      };
}

class RawMaterialDb {
  int? recId;
  String? materialId;
  String? materialName;
  int? categoryId;
  String? ingredient;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? createdBy;
  String? updatedBy;
  String? remark;
  String? remark1;

  RawMaterialDb({
    this.recId,
    this.materialId,
    this.materialName,
    this.categoryId,
    this.ingredient,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.remark,
    this.remark1,
  });

  factory RawMaterialDb.fromJson(Map<String, dynamic> json) => RawMaterialDb(
        recId: json["RecId"],
        materialId: json["MaterialID"],
        materialName: json["MaterialName"],
        categoryId: json["CategoryID"],
        ingredient: json["Ingredient"],
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
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "MaterialID": materialId,
        "MaterialName": materialName,
        "CategoryID": categoryId,
        "Ingredient": ingredient,
        "CreatedAt": createdAt?.toIso8601String(),
        "UpdatedAt": updatedAt?.toIso8601String(),
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "Remark": remark,
        "Remark1": remark1,
      };
}

class Header {
  FormulaHeader? formulaHeader;
  String? formulaCategoryName;

  Header({
    this.formulaHeader,
    this.formulaCategoryName,
  });

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        formulaHeader: json["FormulaHeader"] == null
            ? null
            : FormulaHeader.fromJson(json["FormulaHeader"]),
        formulaCategoryName: json["FormulaCategoryName"],
      );

  Map<String, dynamic> toJson() => {
        "FormulaHeader": formulaHeader?.toJson(),
        "FormulaCategoryName": formulaCategoryName,
      };
}

class FormulaHeader {
  int? recId;
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

  FormulaHeader({
    this.recId,
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
  });

  factory FormulaHeader.fromJson(Map<String, dynamic> json) => FormulaHeader(
        recId: json["RecId"],
        formulaId: json["FormulaID"],
        formulaName: json["FormulaName"],
        categoryId: json["CategoryID"],
        formulaMode: json["FormulaMode"],
        formulaUnit: json["FormulaUnit"],
        totalWeight: (json["TotalWeight"] as num?)?.toDouble(),
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
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
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
      };
}
