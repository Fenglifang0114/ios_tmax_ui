// To parse this JSON data, do
//
//     final reqGetAllWgtRecs = reqGetAllWgtRecsFromJson(jsonString);

import 'dart:convert';

ReqGetAllWgtRecs reqGetAllWgtRecsFromJson(String str) =>
    ReqGetAllWgtRecs.fromJson(json.decode(str));

String reqGetAllWgtRecsToJson(ReqGetAllWgtRecs data) =>
    json.encode(data.toJson());

class ReqGetAllWgtRecs {
  int? mode;
  int? page;
  int? pageSize;
  String? columnName;
  String? direction;

  ReqGetAllWgtRecs({
    this.mode,
    this.page,
    this.pageSize,
    this.columnName,
    this.direction,
  });

  factory ReqGetAllWgtRecs.fromJson(Map<String, dynamic> json) =>
      ReqGetAllWgtRecs(
        mode: json["Mode"],
        page: json["Page"],
        pageSize: json["PageSize"],
        columnName: json["ColumnName"],
        direction: json["Direction"],
      );

  Map<String, dynamic> toJson() => {
        "Mode": mode,
        "Page": page,
        "PageSize": pageSize,
        "ColumnName": columnName,
        "Direction": direction,
      };
}

//从数据库获取的数据
// To parse this JSON data, do
//
//     final revAllWgtRecs = revAllWgtRecsFromJson(jsonString);

RevAllWgtRecs revAllWgtRecsFromJson(String str) {
  if (str.trim().isEmpty) return RevAllWgtRecs(scaleRecInfos: [], totalCount: 0);
  try {
    final decoded = json.decode(str);
    if (decoded is List) {
      List<ScaleRecInfo> list = [];
      for (var item in decoded) {
        if (item is Map) {
          list.add(ScaleRecInfo.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return RevAllWgtRecs(scaleRecInfos: list, totalCount: list.length);
    } else if (decoded is Map) {
      return RevAllWgtRecs.fromJson(Map<String, dynamic>.from(decoded));
    }
  } catch (e) {
    // 捕获顶层解析失败
  }
  return RevAllWgtRecs(scaleRecInfos: [], totalCount: 0);
}

String revAllWgtRecsToJson(RevAllWgtRecs data) => json.encode(data.toJson());

class RevAllWgtRecs {
  List<ScaleRecInfo>? scaleRecInfos;
  int? totalCount;

  RevAllWgtRecs({
    this.scaleRecInfos,
    this.totalCount,
  });

  factory RevAllWgtRecs.fromJson(Map<String, dynamic> json) {
    var recs = json["scale_rec_infos"] ?? json["ScaleRecInfos"] ?? json["scaleRecInfos"] ?? json["scale_rec_info"];
    var count = json["total_count"] ?? json["TotalCount"] ?? json["totalCount"];
    List<ScaleRecInfo> parsedList = [];
    if (recs is List) {
      for (var item in recs) {
        if (item is Map) {
          try {
            parsedList.add(ScaleRecInfo.fromJson(Map<String, dynamic>.from(item)));
          } catch (e) {
            // 单条记录解析失败不影响其他记录
          }
        }
      }
    }
    return RevAllWgtRecs(
      scaleRecInfos: parsedList,
      totalCount: count is int ? count : (int.tryParse(count?.toString() ?? '0') ?? parsedList.length),
    );
  }

  Map<String, dynamic> toJson() => {
        "scale_rec_infos": scaleRecInfos == null
            ? []
            : List<dynamic>.from(scaleRecInfos!.map((x) => x.toJson())),
        "total_count": totalCount,
      };
}

class ScaleRecInfo {
  Header? header;
  List<NewWgtDetail>? details;

  ScaleRecInfo({
    this.header,
    this.details,
  });

  factory ScaleRecInfo.fromJson(Map<String, dynamic> json) {
    var headData = json["Header"] ?? json["header"] ?? json["headRec"] ?? json["HeadRec"];
    var detailsData = json["Details"] ?? json["details"] ?? json["detailRec"] ?? json["DetailRec"];
    return ScaleRecInfo(
      header: headData == null ? null : Header.fromJson(Map<String, dynamic>.from(headData)),
      details: detailsData == null
          ? []
          : List<NewWgtDetail>.from(
              detailsData.map((x) => NewWgtDetail.fromJson(Map<String, dynamic>.from(x)))),
    );
  }

  Map<String, dynamic> toJson() => {
        "Header": header?.toJson(),
        "Details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class NewWgtDetail {
  int? recId;
  int? headId;
  int? no;
  String? scaleModel;
  String? scaleSn;
  String? weight;
  String? weightUnit;
  String? scaleName;
  DateTime? createdAt;

  NewWgtDetail({
    this.recId,
    this.headId,
    this.no,
    this.scaleModel,
    this.scaleSn,
    this.weight,
    this.weightUnit,
    this.scaleName,
    this.createdAt,
  });

  factory NewWgtDetail.fromJson(Map<String, dynamic> json) => NewWgtDetail(
        recId: json["RecId"] ?? json["recId"] ?? json["rec_id"],
        headId: json["HeadId"] ?? json["headId"] ?? json["head_id"],
        no: json["No"] ?? json["no"],
        scaleModel: json["ScaleModel"] ?? json["scaleModel"] ?? json["scale_model"],
        scaleSn: json["ScaleSn"] ?? json["scaleSn"] ?? json["scale_sn"],
        weight: json["Weight"]?.toString() ?? json["weight"]?.toString(),
        weightUnit: json["WeightUnit"]?.toString() ?? json["weightUnit"]?.toString() ?? json["weight_unit"]?.toString(),
        scaleName: json["ScaleName"] ?? json["scaleName"] ?? json["scale_name"],
        createdAt: json["CreatedAt"] == null && json["createdAt"] == null && json["created_at"] == null
            ? null
            : DateTime.tryParse((json["CreatedAt"] ?? json["createdAt"] ?? json["created_at"]).toString())?.toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "HeadId": headId,
        "No": no,
        "ScaleModel": scaleModel,
        "ScaleSn": scaleSn,
        "Weight": weight,
        "WeightUnit": weightUnit,
        "ScaleName": scaleName,
        "CreatedAt": createdAt?.toIso8601String(),
      };
}

class Header {
  int? recId;
  String? id;
  String? scaleModel;
  String? scaleSn;
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
  String? weight;
  String? weightUnit;
  String? userNo;
  String? userName;
  String? scaleMode;
  String? scaleName;
  DateTime? createdAt;

  Header({
    this.recId,
    this.id,
    this.scaleModel,
    this.scaleSn,
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
    this.weight,
    this.weightUnit,
    this.userNo,
    this.userName,
    this.scaleMode,
    this.scaleName,
    this.createdAt,
  });

  Header copyWith({
    String? id,
    String? scaleModel,
    String? scaleSn,
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
    String? weight,
    String? weightUnit,
    String? userNo,
    String? userName,
    String? scaleMode,
    String? scaleName,
    DateTime? createdAt,
  }) =>
      Header(
        id: id ?? this.id,
        scaleModel: scaleModel ?? this.scaleModel,
        scaleSn: scaleSn ?? this.scaleSn,
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
        weight: weight ?? this.weight,
        weightUnit: weightUnit ?? this.weightUnit,
        userNo: userNo ?? this.userNo,
        userName: userName ?? this.userName,
        scaleMode: scaleMode ?? this.scaleMode,
        scaleName: scaleName ?? this.scaleName,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        recId: int.tryParse((json["RecId"] ?? json["recId"] ?? json["rec_id"] ?? json["RecID"])?.toString() ?? ''),
        id: json["Id"]?.toString() ?? json["id"]?.toString(),
        scaleModel: json["ScaleModel"] ?? json["scaleModel"] ?? json["scale_model"],
        scaleSn: json["ScaleSn"] ?? json["scaleSn"] ?? json["scale_sn"],
        plu: json["Plu"]?.toString() ?? json["plu"]?.toString(),
        productCode: json["ProductCode"]?.toString() ?? json["productCode"]?.toString() ?? json["product_code"]?.toString(),
        itemCode: json["ItemCode"]?.toString() ?? json["itemCode"]?.toString() ?? json["item_code"]?.toString(),
        category: json["Category"] ?? json["category"],
        productName: json["ProductName"] ?? json["productName"] ?? json["product_name"],
        generalUnit: json["GeneralUnit"]?.toString() ?? json["generalUnit"]?.toString(),
        taxType: json["TaxType"]?.toString() ?? json["taxType"]?.toString(),
        price: json["Price"]?.toString() ?? json["price"]?.toString(),
        unitWeight: json["UnitWeight"]?.toString() ?? json["unitWeight"]?.toString(),
        pretare: json["Pretare"]?.toString() ?? json["pretare"]?.toString(),
        limitHigh: json["LimitHigh"]?.toString() ?? json["limitHigh"]?.toString(),
        limitLow: json["LimitLow"]?.toString() ?? json["limitLow"]?.toString(),
        weight: json["Weight"]?.toString() ?? json["weight"]?.toString(),
        weightUnit: json["WeightUnit"]?.toString() ?? json["weightUnit"]?.toString() ?? json["weight_unit"]?.toString(),
        userNo: json["UserNo"]?.toString() ?? json["userNo"]?.toString(),
        userName: json["UserName"] ?? json["userName"],
        scaleMode: json["ScaleMode"]?.toString() ?? json["scaleMode"]?.toString(),
        scaleName: json["ScaleName"] ?? json["scaleName"] ?? json["scale_name"],
        createdAt: json["CreatedAt"] == null && json["createdAt"] == null && json["created_at"] == null
            ? null
            : DateTime.tryParse((json["CreatedAt"] ?? json["createdAt"] ?? json["created_at"]).toString())?.toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "Id": id,
        "ScaleModel": scaleModel,
        "ScaleSn": scaleSn,
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
        "Weight": weight,
        "WeightUnit": weightUnit,
        "UserNo": userNo,
        "UserName": userName,
        "ScaleMode": scaleMode,
        "ScaleName": scaleName,
        "CreatedAt": createdAt?.toIso8601String(),
      };
}

//以上解析

ReqDelAllWgtRecs reqDelAllWgtRecsFromJson(String str) =>
    ReqDelAllWgtRecs.fromJson(json.decode(str));

String reqDelAllWgtRecsToJson(ReqDelAllWgtRecs data) =>
    json.encode(data.toJson());

class ReqDelAllWgtRecs {
  int? mode;

  ReqDelAllWgtRecs({
    this.mode,
  });

  factory ReqDelAllWgtRecs.fromJson(Map<String, dynamic> json) =>
      ReqDelAllWgtRecs(
        mode: json["Mode"],
      );

  Map<String, dynamic> toJson() => {
        "Mode": mode,
      };
}

//请求增加汇总的称重记录

ReqAddWgtRec reqAddWgtRecFromJson(String str) =>
    ReqAddWgtRec.fromJson(json.decode(str));

String reqAddWgtRecToJson(ReqAddWgtRec data) => json.encode(data.toJson());

class ReqAddWgtRec {
  int? mode;
  Header? headRec;
  List<NewWgtDetail>? detailRec;

  ReqAddWgtRec({
    this.mode,
    this.headRec,
    this.detailRec,
  });

  factory ReqAddWgtRec.fromJson(Map<String, dynamic> json) => ReqAddWgtRec(
        mode: json["Mode"],
        headRec:
            json["HeadRec"] == null ? null : Header.fromJson(json["HeadRec"]),
        detailRec: json["DetailRec"] == null
            ? []
            : List<NewWgtDetail>.from(
                json["DetailRec"]!.map((x) => NewWgtDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Mode": mode,
        "HeadRec": headRec?.toJson(),
        "DetailRec": detailRec == null
            ? []
            : List<dynamic>.from(detailRec!.map((x) => x.toJson())),
      };
}

//请求导出所有数据

String reqExportAllWgtRecsToJson(ReqExportAllWgtRecs data) =>
    json.encode(data.toJson());

class ReqExportAllWgtRecs {
  int? mode;
  String? path;
  List<String>? fieldName;
  Map<String, String>? translation;
  int? timezoneOffset;

  ReqExportAllWgtRecs({
    this.mode,
    this.path,
    this.fieldName,
    this.translation,
    this.timezoneOffset,
  });

  Map<String, dynamic> toJson() => {
        "Mode": mode,
        "Path": path,
        "FieldName": fieldName,
        "Translation": translation,
        "TimezoneOffset": timezoneOffset,
      };
}
