// To parse this JSON data, do
//
//     final pluInfoList = pluInfoListFromJson(jsonString);

import 'dart:convert';

// List<PluInfoList> pluInfoListFromJson(String str) {
//   try {
//     return List<PluInfoList>.from(
//         json.decode(str).map((x) => PluInfoList.fromJson(x)));
//   } catch (e) {
//     print(e);
//     return [];
//   }
// }

List<PluInfoList> pluInfoListFromJson(String str) {
  try {
    final List<dynamic> jsonList = json.decode(str);
    final List<PluInfoList> result = [];
    for (var i = 0; i < jsonList.length; i++) {
      try {
        final PluInfoList item = PluInfoList.fromJson(jsonList[i]);
        result.add(item);
      } catch (e) {
        break;
      }
    }
    return result;
  } catch (e) {
    return [];
  }
}

String pluInfoListToJson(List<PluInfoList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PluInfoList {
  int recId;
  String plu;
  String productCode;
  String itemCode;
  String category;
  String productName;
  String generalUnit;
  String taxType;
  String price;
  String unitWeight;
  String pretare;
  String limitHigh;
  String limitLow;
  String? creatAt;

  PluInfoList({
    required this.recId,
    required this.plu,
    required this.productCode,
    required this.itemCode,
    required this.category,
    required this.productName,
    required this.generalUnit,
    required this.taxType,
    required this.price,
    required this.unitWeight,
    required this.pretare,
    required this.limitHigh,
    required this.limitLow,
    required this.creatAt,
  });

  factory PluInfoList.fromJson(Map<String, dynamic> json) => PluInfoList(
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
        creatAt: json["CreatAt"],
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
        "CreatAt": creatAt,
      };
}

List<PluInfoList> myPluListFormDb = [];
