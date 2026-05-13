import 'dart:convert';

List<RawDataInfo> rawDataInfoFromJson(String str) => List<RawDataInfo>.from(
    json.decode(str).map((x) => RawDataInfo.fromJson(x)));

String rawDataInfoToJson(List<RawDataInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RawDataInfo {
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
  int? scaleId;
  String? checkCode;
  int? output;

  RawDataInfo({
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
    this.scaleId,
    this.checkCode,
    this.output,
  });

  factory RawDataInfo.fromJson(Map<String, dynamic> json) => RawDataInfo(
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
        scaleId: json["ScaleId"],
        checkCode: json["CheckCode"],
        output: json["Output"],
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
        "ScaleId": scaleId,
        "CheckCode": checkCode,
        "Output": output,
      };
}

// 配方头表
class FormulaHeader {
  int? recId;
  String formulaID;
  String formulaName;
  int categoryID;
  String formulaMode;
  String? formulaUnit;
  double? totalWeight;
  int materialCount;
  bool isEncrypted;
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
    required this.formulaID,
    required this.formulaName,
    required this.categoryID,
    required this.formulaMode,
    this.formulaUnit,
    this.totalWeight,
    required this.materialCount,
    required this.isEncrypted,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.remark,
    this.remark1,
    this.remark2,
    this.remark3,
  });

  factory FormulaHeader.fromJson(Map<String, dynamic> json) {
    return FormulaHeader(
      recId: json['RecId'],
      formulaID: json['FormulaID'],
      formulaName: json['FormulaName'],
      categoryID: json['CategoryID'],
      formulaMode: json['FormulaMode'] ?? '',
      formulaUnit: json['FormulaUnit'] ?? '',
      totalWeight: json['TotalWeight']?.toDouble() ?? 0.0,
      materialCount: json['MaterialCount'],
      isEncrypted: json['IsEncrypted'],
      createdAt: DateTime.parse(json['CreatedAt']).toLocal(),
      updatedAt: DateTime.parse(json['UpdatedAt']).toLocal(),
      createdBy: json['CreatedBy'] ?? '',
      updatedBy: json['UpdatedBy'] ?? '',
      remark: json['Remark'] ?? '',
      remark1: json['Remark1'] ?? '',
      remark2: json['Remark2'] ?? '',
      remark3: json['Remark3'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RecId': recId,
      'FormulaID': formulaID,
      'FormulaName': formulaName,
      'CategoryID': categoryID,
      'FormulaMode': formulaMode,
      'FormulaUnit': formulaUnit,
      'TotalWeight': totalWeight,
      'MaterialCount': materialCount,
      'IsEncrypted': isEncrypted,
      'CreatedAt': createdAt!.toIso8601String(),
      'UpdatedAt': updatedAt!.toIso8601String(),
      'CreatedBy': createdBy,
      'UpdatedBy': updatedBy,
      'Remark': remark,
      'Remark1': remark1,
      'Remark2': remark2,
      'Remark3': remark3,
    };
  }
}

// 配方明细表
class FormulaDetail {
  int recId;
  String formulaID;
  String materialID;
  double? materialWeight;
  double? materialPct;
  int sequence;
  double allowError;
  String? remark;
  String? remark1;

  FormulaDetail({
    required this.recId,
    required this.formulaID,
    required this.materialID,
    this.materialWeight,
    this.materialPct,
    required this.sequence,
    required this.allowError,
    this.remark,
    this.remark1,
  });

  factory FormulaDetail.fromJson(Map<String, dynamic> json) {
    return FormulaDetail(
      recId: json['RecId'],
      formulaID: json['FormulaID'],
      materialID: json['MaterialID'],
      materialWeight: json['MaterialWeight']?.toDouble() ?? 0.0,
      materialPct: json['MaterialPercentage']?.toDouble() ?? 0.0,
      sequence: json['Sequence'],
      allowError: json['AllowableError']?.toDouble() ?? 0.0,
      remark: json['Remark'] ?? '',
      remark1: json['Remark1'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RecId': recId,
      'FormulaID': formulaID,
      'MaterialID': materialID,
      'MaterialWeight': materialWeight,
      'MaterialPercentage': materialPct,
      'Sequence': sequence,
      'AllowableError': allowError,
      'Remark': remark,
      'Remark1': remark1,
    };
  }
}

// 配方称重记录头表
class FormulaWgtRecHeader {
  int? recId;
  String recordID;
  DateTime? recordSaveTime;
  String? operator;
  int formulaID;
  String formulaName;
  String formulaCategory;
  String formulaMode;
  double? totalWeight;
  String? totalWeightUnit;
  int materialCount;
  double? totalMaterialWeight;
  String? totalMaterialWeightUnit;
  double? error;
  String? isQualified;
  bool isEncrypted;
  DateTime? formulaCreatedAt;
  DateTime? formulaUpdatedAt;
  String? formulaCreatedBy;
  String? formulaUpdatedBy;
  String? formulaRemark;
  String? formulaRemark1;
  String? recRemark;
  String? recRemark1;
  int? scaleId;
  String? scaleName;
  String? scaleModel;
  String? scaleSn;

  FormulaWgtRecHeader({
    this.recId,
    required this.recordID,
    this.recordSaveTime,
    this.operator,
    required this.formulaID,
    required this.formulaName,
    required this.formulaCategory,
    required this.formulaMode,
    this.totalWeight,
    this.totalWeightUnit,
    required this.materialCount,
    this.totalMaterialWeight,
    this.totalMaterialWeightUnit,
    this.error,
    this.isQualified,
    required this.isEncrypted,
    this.formulaCreatedAt,
    this.formulaUpdatedAt,
    this.formulaCreatedBy,
    this.formulaUpdatedBy,
    this.formulaRemark,
    this.formulaRemark1,
    this.recRemark,
    this.recRemark1,
    this.scaleId,
    this.scaleName,
    this.scaleModel,
    this.scaleSn,
  });

  factory FormulaWgtRecHeader.fromJson(Map<String, dynamic> json) {
    return FormulaWgtRecHeader(
      recId: json['RecId'],
      recordID: json['RecordID'],
      recordSaveTime: DateTime.parse(json['RecordSaveTime']),
      operator: json['Operator'] ?? '',
      formulaID: json['FormulaID'],
      formulaName: json['FormulaName'],
      formulaCategory: json['FormulaCategory'] ?? '',
      formulaMode: json['FormulaMode'] ?? '',
      totalWeight: json['TotalWeight']?.toDouble() ?? 0.0,
      totalWeightUnit: json['TotalWeightUnit'] ?? '',
      materialCount: json['MaterialCount'],
      totalMaterialWeight: json['TotalMaterialWeight']?.toDouble() ?? 0.0,
      totalMaterialWeightUnit: json['TotalMaterialWeightUnit'] ?? '',
      error: json['Error']?.toDouble() ?? 0.0,
      isQualified: json['IsQualified'] ?? '',
      isEncrypted: json['IsEncrypted'],
      formulaCreatedAt: DateTime.parse(json['FormulaCreatedAt']),
      formulaUpdatedAt: DateTime.parse(json['FormulaUpdatedAt']),
      formulaCreatedBy: json['FormulaCreatedBy'] ?? '',
      formulaUpdatedBy: json['FormulaUpdatedBy'] ?? '',
      formulaRemark: json['FormulaRemark'] ?? '',
      formulaRemark1: json['FormulaRemark1'] ?? '',
      recRemark: json['RecRemark'] ?? '',
      recRemark1: json['RecRemark1'] ?? '',
      scaleId: json['ScaleId'],
      scaleName: json['ScaleName'] ?? '',
      scaleModel: json['ScaleModel'] ?? '',
      scaleSn: json['ScaleSn'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RecId': recId,
      'RecordID': recordID,
      'RecordSaveTime': recordSaveTime!.toIso8601String(),
      'Operator': operator,
      'FormulaID': formulaID,
      'FormulaName': formulaName,
      'FormulaCategory': formulaCategory,
      'FormulaMode': formulaMode,
      'TotalWeight': totalWeight,
      'TotalWeightUnit': totalWeightUnit,
      'MaterialCount': materialCount,
      'TotalMaterialWeight': totalMaterialWeight,
      'TotalMaterialWeightUnit': totalMaterialWeightUnit,
      'Error': error,
      'IsQualified': isQualified,
      'IsEncrypted': isEncrypted,
      'FormulaCreatedAt': formulaCreatedAt!.toIso8601String(),
      'FormulaUpdatedAt': formulaUpdatedAt!.toIso8601String(),
      'FormulaCreatedBy': formulaCreatedBy,
      'FormulaUpdatedBy': formulaUpdatedBy,
      'FormulaRemark': formulaRemark,
      'FormulaRemark1': formulaRemark1,
      'RecRemark': recRemark,
      'RecRemark1': recRemark1,
      'ScaleId': scaleId,
      'ScaleName': scaleName,
      'ScaleModel': scaleModel,
      'ScaleSn': scaleSn,
    };
  }
}

// 配方称重记录详情表
class FormulaWgtRecDetail {
  String recordID;
  String materialID;
  String materialCategory;
  String ingredient;
  DateTime materialCreatedAt;
  DateTime materialUpdatedAt;
  String materialCreatedBy;
  String materialUpdatedBy;
  String materialRemark;
  String materialRemark1;
  double materialWeight;
  double materialPercentage;
  int sequence;
  double allowableError;
  String formulaRemark;
  String formulaRemark1;
  double actualWeight;
  String actualWeightUnit;
  double actualPercentage;
  double actualError;
  String isQualified;
  DateTime lastWeighingTime;
  String recRemark;
  String recRemark1;

  FormulaWgtRecDetail({
    required this.recordID,
    required this.materialID,
    required this.materialCategory,
    required this.ingredient,
    required this.materialCreatedAt,
    required this.materialUpdatedAt,
    required this.materialCreatedBy,
    required this.materialUpdatedBy,
    required this.materialRemark,
    required this.materialRemark1,
    required this.materialWeight,
    required this.materialPercentage,
    required this.sequence,
    required this.allowableError,
    required this.formulaRemark,
    required this.formulaRemark1,
    required this.actualWeight,
    required this.actualWeightUnit,
    required this.actualPercentage,
    required this.actualError,
    required this.isQualified,
    required this.lastWeighingTime,
    required this.recRemark,
    required this.recRemark1,
  });

  factory FormulaWgtRecDetail.fromJson(Map<String, dynamic> json) {
    return FormulaWgtRecDetail(
      recordID: json['RecordID'],
      materialID: json['MaterialID'],
      materialCategory: json['MaterialCategory'] ?? '',
      ingredient: json['Ingredient'] ?? '',
      materialCreatedAt: DateTime.parse(json['MaterialCreatedAt']),
      materialUpdatedAt: DateTime.parse(json['MaterialUpdatedAt']),
      materialCreatedBy: json['MaterialCreatedBy'] ?? '',
      materialUpdatedBy: json['MaterialUpdatedBy'] ?? '',
      materialRemark: json['MaterialRemark'] ?? '',
      materialRemark1: json['MaterialRemark1'] ?? '',
      materialWeight: json['MaterialWeight']?.toDouble() ?? 0.0,
      materialPercentage: json['MaterialPercentage']?.toDouble() ?? 0.0,
      sequence: json['Sequence'],
      allowableError: json['AllowableError']?.toDouble() ?? 0.0,
      formulaRemark: json['FormulaRemark'] ?? '',
      formulaRemark1: json['FormulaRemark1'] ?? '',
      actualWeight: json['ActualWeight']?.toDouble() ?? 0.0,
      actualWeightUnit: json['ActualWeightUnit'] ?? '',
      actualPercentage: json['ActualPercentage']?.toDouble() ?? 0.0,
      actualError: json['ActualError']?.toDouble() ?? 0.0,
      isQualified: json['IsQualified'] ?? '',
      lastWeighingTime: DateTime.parse(json['LastWeighingTime']),
      recRemark: json['RecRemark'] ?? '',
      recRemark1: json['RecRemark1'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RecordID': recordID,
      'MaterialID': materialID,
      'MaterialCategory': materialCategory,
      'Ingredient': ingredient,
      'MaterialCreatedAt': materialCreatedAt.toIso8601String(),
      'MaterialUpdatedAt': materialUpdatedAt.toIso8601String(),
      'MaterialCreatedBy': materialCreatedBy,
      'MaterialUpdatedBy': materialUpdatedBy,
      'MaterialRemark': materialRemark,
      'MaterialRemark1': materialRemark1,
      'MaterialWeight': materialWeight,
      'MaterialPercentage': materialPercentage,
      'Sequence': sequence,
      'AllowableError': allowableError,
      'FormulaRemark': formulaRemark,
      'FormulaRemark1': formulaRemark1,
      'ActualWeight': actualWeight,
      'ActualWeightUnit': actualWeightUnit,
      'ActualPercentage': actualPercentage,
      'ActualError': actualError,
      'IsQualified': isQualified,
      'LastWeighingTime': lastWeighingTime.toIso8601String(),
      'RecRemark': recRemark,
      'RecRemark1': recRemark1,
    };
  }
}

// 配方列表
class FormulaList {
  FormulaHeader header;
  List<FormulaDetail> details;

  FormulaList({
    required this.header,
    required this.details,
  });

  factory FormulaList.fromJson(Map<String, dynamic> json) {
    return FormulaList(
      header: FormulaHeader.fromJson(json['Header']),
      details: (json['Details'] as List<dynamic>)
          .map((e) => FormulaDetail.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Header': header.toJson(),
      'Details': details.map((e) => e.toJson()).toList(),
    };
  }
}

// 配方称重记录列表
class FormulaWgtRecList {
  FormulaWgtRecHeader header;
  List<FormulaWgtRecDetail> details;

  FormulaWgtRecList({
    required this.header,
    required this.details,
  });

  factory FormulaWgtRecList.fromJson(Map<String, dynamic> json) {
    return FormulaWgtRecList(
      header: FormulaWgtRecHeader.fromJson(json['Header']),
      details: (json['Details'] as List<dynamic>)
          .map((e) => FormulaWgtRecDetail.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Header': header.toJson(),
      'Details': details.map((e) => e.toJson()).toList(),
    };
  }
}
