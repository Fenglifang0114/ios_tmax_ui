import 'dart:convert';

//配方秤中的类型添加字段
class TypeName {
  String name;
  TypeName(this.name);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Name'] = name;
    return data;
  }
}

//配方秤中的类型添加字段
class TypeIdAndName {
  String name;
  int id;
  TypeIdAndName(this.name, this.id);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Name'] = name;
    data['ID'] = id;

    return data;
  }
}

// To parse this JSON data, do
//
//     final categoryTypeList = categoryTypeListFromJson(jsonString);

List<CategoryTypeList> categoryTypeListFromJson(String str) =>
    List<CategoryTypeList>.from(
        json.decode(str).map((x) => CategoryTypeList.fromJson(x)));

String categoryTypeListToJson(List<CategoryTypeList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryTypeList {
  int categoryId;
  String categoryName;

  CategoryTypeList({
    required this.categoryId,
    required this.categoryName,
  });

  factory CategoryTypeList.fromJson(Map<String, dynamic> json) =>
      CategoryTypeList(
        categoryId: json["CategoryID"],
        categoryName: json["CategoryName"],
      );

  Map<String, dynamic> toJson() => {
        "CategoryID": categoryId,
        "CategoryName": categoryName,
      };
}

String addRawDataToJson(AddRawData data) => json.encode(data.toJson());

class AddRawData {
  String materialId;
  String materialName;
  int categoryId;
  String ingredient;
  String createdBy;
  String updatedBy;
  String remark;
  String remark1;

  AddRawData({
    required this.materialId,
    required this.materialName,
    required this.categoryId,
    required this.ingredient,
    required this.createdBy,
    required this.updatedBy,
    required this.remark,
    required this.remark1,
  });

  Map<String, dynamic> toJson() => {
        "MaterialID": materialId,
        "MaterialName": materialName,
        "CategoryID": categoryId,
        "Ingredient": ingredient,
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "Remark": remark,
        "Remark1": remark1,
      };
}

String editRawDataToJson(EditRawData data) => json.encode(data.toJson());

class EditRawData {
  int recId;
  String materialId;
  String materialName;
  int categoryId;
  String ingredient;
  String createdBy;
  String updatedBy;
  String remark;
  String remark1;

  EditRawData({
    required this.recId,
    required this.materialId,
    required this.materialName,
    required this.categoryId,
    required this.ingredient,
    required this.createdBy,
    required this.updatedBy,
    required this.remark,
    required this.remark1,
  });

  Map<String, dynamic> toJson() => {
        "RecID": recId,
        "MaterialID": materialId,
        "MaterialName": materialName,
        "CategoryID": categoryId,
        "Ingredient": ingredient,
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "Remark": remark,
        "Remark1": remark1,
      };
}

class DeleteRawDataId {
  int recId;
  DeleteRawDataId({required this.recId});
  Map<String, dynamic> toJson() => {
        "RecID": recId,
      };
}

// To parse this JSON data, do
//
//     final formulaAddInfo = formulaAddInfoFromJson(jsonString);
//增加配方存数据库
ReqFormulaAddInfo formulaAddInfoFromJson(String str) =>
    ReqFormulaAddInfo.fromJson(json.decode(str));

String formulaAddInfoToJson(ReqFormulaAddInfo data) =>
    json.encode(data.toJson());

class ReqFormulaAddInfo {
  ReqFormulaHeader? header;
  List<ReqFormulaDetail>? detail;

  ReqFormulaAddInfo({
    this.header,
    this.detail,
  });

  factory ReqFormulaAddInfo.fromJson(Map<String, dynamic> json) =>
      ReqFormulaAddInfo(
        header: json["Header"] == null
            ? null
            : ReqFormulaHeader.fromJson(json["Header"]),
        detail: json["Detail"] == null
            ? []
            : List<ReqFormulaDetail>.from(
                json["Detail"]!.map((x) => ReqFormulaDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Header": header?.toJson(),
        "Detail": detail == null
            ? []
            : List<dynamic>.from(detail!.map((x) => x.toJson())),
      };
}

class ReqFormulaDetail {
  String? formulaId;
  String? materialId;
  double? materialWeight;
  double? materialPercentage;
  int? sequence;
  double? allowableError;
  String? remark;

  ReqFormulaDetail({
    this.formulaId,
    this.materialId,
    this.materialWeight,
    this.materialPercentage,
    this.sequence,
    this.allowableError,
    this.remark,
  });

  factory ReqFormulaDetail.fromJson(Map<String, dynamic> json) =>
      ReqFormulaDetail(
        formulaId: json["FormulaID"],
        materialId: json["MaterialID"],
        materialWeight: json["MaterialWeight"],
        materialPercentage: json["MaterialPercentage"],
        sequence: json["Sequence"],
        allowableError: json["AllowableError"]?.toDouble(),
        remark: json["Remark"],
      );

  Map<String, dynamic> toJson() => {
        "FormulaID": formulaId,
        "MaterialID": materialId,
        "MaterialWeight": materialWeight,
        "MaterialPercentage": materialPercentage,
        "Sequence": sequence,
        "AllowableError": allowableError,
        "Remark": remark,
      };
}

class ReqFormulaHeader {
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
  String? createdBy;
  String? updatedBy;
  String? remark;

  ReqFormulaHeader({
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
    this.createdBy,
    this.updatedBy,
    this.remark,
  });

  factory ReqFormulaHeader.fromJson(Map<String, dynamic> json) =>
      ReqFormulaHeader(
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
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        remark: json["Remark"],
      );

  Map<String, dynamic> toJson() => {
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
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "Remark": remark,
      };
}

class DeleteDraftFmaId {
  String orderId;
  DeleteDraftFmaId({required this.orderId});
  Map<String, dynamic> toJson() => {
        "OrderID": orderId,
      };
}
