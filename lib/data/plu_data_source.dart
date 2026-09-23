import 'dart:convert';

List<PluData> myPluInfoList = [];

class PluData {
  int? recId;
  int? plu;
  int? productCode;
  int? itemCode;
  String? category;
  String? productName;
  int? generalUnit;
  int? taxType;
  double? price;
  double? unitWeight;
  double? pretare;
  double? limitHigh;
  double? limitLow;
  String? creatAt;
  bool? enabled;
  String? updateAt;
  int? createBy;
  int? updateBy;
  String? createUser;
  String? updateUser;

  PluData(
    this.recId,
    this.plu,
    this.productCode,
    this.itemCode,
    this.category,
    this.productName,
    this.generalUnit,
    this.taxType,
    this.price,
    this.unitWeight,
    this.pretare,
    this.limitHigh,
    this.limitLow,
    this.creatAt,
    this.enabled,
    this.updateAt,
    this.createBy,
    this.updateBy,
    this.createUser,
    this.updateUser,
  );
}

List<PluDataFromDb> pluDataFromDbFromJson(String str) =>
    List<PluDataFromDb>.from(
        json.decode(str).map((x) => PluDataFromDb.fromJson(x)));

String pluDataFromDbToJson(List<PluDataFromDb> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PluDataFromDb {
  int? recId;
  String? plu;
  String? productCode;
  String? itemCode;
  String? category;
  String? productName;
  String? generalUnit;
  String? taxType;
  String? price;
  String? unitWeight;
  String? pretare;
  String? limitHigh;
  String? limitLow;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? createBy;
  int? updateBy;
  bool? enabled;
  String? createUser;
  String? updateUser;

  PluDataFromDb({
    this.recId,
    this.plu,
    this.productCode,
    this.itemCode,
    this.category,
    this.productName,
    this.generalUnit,
    this.taxType,
    this.price,
    this.unitWeight,
    this.pretare,
    this.limitHigh,
    this.limitLow,
    this.createdAt,
    this.updatedAt,
    this.createBy,
    this.updateBy,
    this.enabled,
    this.createUser,
    this.updateUser,
  });

  PluDataFromDb copyWith({
    int? recId,
    String? plu,
    String? productCode,
    String? itemCode,
    String? category,
    String? productName,
    String? generalUnit,
    String? taxType,
    String? price,
    String? unitWeight,
    String? pretare,
    String? limitHigh,
    String? limitLow,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createBy,
    int? updateBy,
    bool? enabled,
    String? createUser,
    String? updateUser,
  }) =>
      PluDataFromDb(
        recId: recId ?? this.recId,
        plu: plu ?? this.plu,
        productCode: productCode ?? this.productCode,
        itemCode: itemCode ?? this.itemCode,
        category: category ?? this.category,
        productName: productName ?? this.productName,
        generalUnit: generalUnit ?? this.generalUnit,
        taxType: taxType ?? this.taxType,
        price: price ?? this.price,
        unitWeight: unitWeight ?? this.unitWeight,
        pretare: pretare ?? this.pretare,
        limitHigh: limitHigh ?? this.limitHigh,
        limitLow: limitLow ?? this.limitLow,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        createBy: createBy ?? this.createBy,
        updateBy: updateBy ?? this.updateBy,
        enabled: enabled ?? this.enabled,
        createUser: createUser ?? this.createUser,
        updateUser: updateUser ?? this.updateUser,
      );

  factory PluDataFromDb.fromJson(Map<String, dynamic> json) => PluDataFromDb(
        recId: json["RecId"],
        plu: json["Plu"],
        productCode: json["ProductCode"],
        itemCode: json["ItemCode"],
        category: json["Category"],
        productName: json["ProductName"],
        generalUnit: json["GeneralUnit"],
        taxType: json["TaxType"],
        price: json["Price"],
        unitWeight: json["UnitWeight"],
        pretare: json["Pretare"],
        limitHigh: json["LimitHigh"],
        limitLow: json["LimitLow"],
        createdAt: json["CreatedAt"] == null || json["CreatedAt"] == ""
            ? null
            : DateTime.tryParse(json["CreatedAt"])?.toLocal(),
        updatedAt: json["UpdatedAt"] == null || json["UpdatedAt"] == ""
            ? null
            : DateTime.tryParse(json["UpdatedAt"])?.toLocal(),
        createBy: json["CreateBy"],
        updateBy: json["UpdateBy"],
        enabled: json["Enabled"],
        createUser: json["CreateUser"],
        updateUser: json["UpdateUser"],
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "Plu": plu,
        "ProductCode": productCode,
        "ItemCode": itemCode,
        "Category": category,
        "ProductName": productName,
        "GeneralUnit": generalUnit,
        "TaxType": taxType,
        "Price": price,
        "UnitWeight": unitWeight,
        "Pretare": pretare,
        "LimitHigh": limitHigh,
        "LimitLow": limitLow,
        "CreatedAt": createdAt?.toIso8601String(),
        "UpdatedAt": updatedAt?.toIso8601String(),
        "CreateBy": createBy,
        "UpdateBy": updateBy,
        "Enabled": enabled,
        "CreateUser": createUser,
        "UpdateUser": updateUser,
      };
}

String reqEnabledPluToJson(ReqEnabledPlu data) => json.encode(data.toJson());

class ReqEnabledPlu {
  List<int>? pluList;
  bool? enabled;
  String? updateBy;

  ReqEnabledPlu({
    this.pluList,
    this.enabled,
    this.updateBy,
  });

  factory ReqEnabledPlu.fromJson(Map<String, dynamic> json) => ReqEnabledPlu(
        pluList: json["PluList"] == null
            ? []
            : List<int>.from(json["PluList"]!.map((x) => x)),
        enabled: json["Enabled"],
        updateBy: json["UpdateBy"],
      );

  Map<String, dynamic> toJson() => {
        "PluList":
            pluList == null ? [] : List<dynamic>.from(pluList!.map((x) => x)),
        "Enabled": enabled,
        "UpdateBy": updateBy,
      };
}

String reqDelPluToJson(ReqDelPlu data) => json.encode(data.toJson());

class ReqDelPlu {
  List<int>? recId;

  ReqDelPlu({
    this.recId,
  });

  Map<String, dynamic> toJson() => {
        "RecId": recId == null ? [] : List<dynamic>.from(recId!.map((x) => x)),
      };
}

String reqAddPluToJson(ReqImportPlu data) => json.encode(data.toJson());

class ReqImportPlu {
  List<PluDataFromDb>? pluList;
  int? total;
  int? index;

  ReqImportPlu({
    this.pluList,
    this.total,
    this.index,
  });

  Map<String, dynamic> toJson() => {
        "PluList": pluList == null
            ? []
            : List<dynamic>.from(pluList!.map((x) => x.toJson())),
        "Total": total,
        "Index": index,
      };
}

class ReqGetPluByPage {
  int? pageSize;
  int? page;
  String? fieldName;
  String? direction;
  SearchPlu? search;

  ReqGetPluByPage({
    this.pageSize,
    this.page,
    this.fieldName,
    this.direction,
    this.search,
  });

  Map<String, dynamic> toJson() => {
        "PageSize": pageSize,
        "Page": page,
        "FieldName": fieldName,
        "Direction": direction,
        "Search": search?.toJson(),
      };
}

class SearchPlu {
  String? plu;
  String? category;
  String? pluName;
  bool? enabled;
  bool? setEnabled;

  SearchPlu({
    this.plu,
    this.category,
    this.pluName,
    this.enabled,
    this.setEnabled,
  });

  Map<String, dynamic> toJson() => {
        "Plu": plu,
        "Category": category,
        "PluName": pluName,
        "Enabled": enabled,
        "SetEnabled": setEnabled,
      };
}

RevGetPlu reqAddPluFromJson(String str) => RevGetPlu.fromJson(json.decode(str));

class RevGetPlu {
  List<PluDataFromDb>? pluList;
  int? total;

  RevGetPlu({
    this.pluList,
    this.total,
  });

  factory RevGetPlu.fromJson(Map<String, dynamic> json) => RevGetPlu(
        pluList: json["PluList"] == null
            ? []
            : List<PluDataFromDb>.from(
                json["PluList"]!.map((x) => PluDataFromDb.fromJson(x))),
        total: json["Total"],
      );

  Map<String, dynamic> toJson() => {
        "PluList": pluList == null
            ? []
            : List<dynamic>.from(pluList!.map((x) => x.toJson())),
        "Total": total,
      };
}

class ExportPlu {
  Map<String, String>? translation;
  SearchPlu? searchPlu;
  String? path;

  ExportPlu({
    this.translation,
    this.searchPlu,
    this.path,
  });
  Map<String, dynamic> toJson() => {
        "Translation": translation,
        "SearchPlu": searchPlu?.toJson(),
        "Path": path,
      };
}

SetPluFields setPluFieldsFromJson(String str) =>
    SetPluFields.fromJson(json.decode(str));

String setPluFieldsToJson(SetPluFields data) => json.encode(data.toJson());

class SetPluFields {
  List<String>? selPlu;

  SetPluFields({
    this.selPlu,
  });

  factory SetPluFields.fromJson(Map<String, dynamic> json) => SetPluFields(
        selPlu: json["plu"] == null
            ? []
            : List<String>.from(json["plu"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "plu": selPlu == null ? [] : List<dynamic>.from(selPlu!.map((x) => x)),
      };
}
