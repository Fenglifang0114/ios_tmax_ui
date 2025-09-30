// To parse this JSON data, do
//
//     final detailInfoRev = detailInfoRevFromJson(jsonString);

import 'dart:convert';

List<DetailInfoRev> detailInfoRevFromJson(String str) =>
    List<DetailInfoRev>.from(
        json.decode(str).map((x) => DetailInfoRev.fromJson(x)));

class DetailInfoRev {
  Total total;
  List<Detail> details;

  DetailInfoRev({
    required this.total,
    required this.details,
  });

  factory DetailInfoRev.fromJson(Map<String, dynamic> json) => DetailInfoRev(
        total: Total.fromJson(json["Total"]),
        details:
            List<Detail>.from(json["Details"].map((x) => Detail.fromJson(x))),
      );
}

class Detail {
  int recId;
  String scaleModel;
  String scaleSn;
  String settleAccountTimes;
  String pluIndex;
  String pluNum;
  String pluTotalPrice;
  String pluUnitPrice;
  String pluTotalWeight;
  String pluTare;
  String pluQuantity;
  String pluUnit;
  String pluTaxType;
  String pluReturnFlag;
  String pluYear;
  String pluMonth;
  String pluDay;
  String pluTaxPrice;
  String pluChangeType;
  String pluName;
  DateTime createdAt;

  Detail({
    required this.recId,
    required this.scaleModel,
    required this.scaleSn,
    required this.settleAccountTimes,
    required this.pluIndex,
    required this.pluNum,
    required this.pluTotalPrice,
    required this.pluUnitPrice,
    required this.pluTotalWeight,
    required this.pluTare,
    required this.pluQuantity,
    required this.pluUnit,
    required this.pluTaxType,
    required this.pluReturnFlag,
    required this.pluYear,
    required this.pluMonth,
    required this.pluDay,
    required this.pluTaxPrice,
    required this.pluChangeType,
    required this.pluName,
    required this.createdAt,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        recId: json["RecId"],
        scaleModel: json["ScaleModel"],
        scaleSn: json["ScaleSn"],
        settleAccountTimes: json["SettleAccountTimes"],
        pluIndex: json["PluIndex"],
        pluNum: json["PluNum"],
        pluTotalPrice: json["PluTotalPrice"],
        pluUnitPrice: json["PluUnitPrice"],
        pluTotalWeight: json["PluTotalWeight"],
        pluTare: json["PluTare"],
        pluQuantity: json["PluQuantity"],
        pluUnit: json["PluUnit"] == "0"
            ? "kg"
            : json["PluUnit"] == "1"
                ? "100g"
                : json["PluUnit"] == "2"
                    ? "pcs"
                    : json["PluUnit"],
        pluTaxType: json["PluTaxType"] == "0"
            ? "Tax1"
            : json["PluTaxType"] == "1"
                ? "Tax2"
                : json["PluTaxType"] == "2"
                    ? "Tax3"
                    : json["PluTaxType"] == "9"
                        ? " "
                        : json["PluTaxType"],
        pluReturnFlag: json["PluReturnFlag"] == "0"
            ? "Normal"
            : json["PluReturnFlag"] == "1"
                ? "Return"
                : json["PluReturnFlag"] == "2"
                    ? "Cancel"
                    : json["PluReturnFlag"],
        pluYear: json["PluYear"],
        pluMonth: json["PluMonth"],
        pluDay: json["PluDay"],
        pluTaxPrice: json["PluTaxPrice"],
        pluChangeType: json["PluChangeType"] == "0"
            ? "Cash"
            : json["PluChangeType"] == "1"
                ? "Card"
                : json["PluChangeType"],
        pluName: json["PluName"],
        createdAt: DateTime.parse(json["CreatedAt"]).toLocal(),
      );
}

class Total {
  int recId;
  String scaleModel;
  String scaleSn;
  String settleAccountTimes;
  String totalCount;
  String payPrice;
  String totalPrice;
  String taxKind;
  DateTime createdAt;

  Total({
    required this.recId,
    required this.scaleModel,
    required this.scaleSn,
    required this.settleAccountTimes,
    required this.totalCount,
    required this.payPrice,
    required this.totalPrice,
    required this.taxKind,
    required this.createdAt,
  });

  factory Total.fromJson(Map<String, dynamic> json) => Total(
        recId: json["RecId"],
        scaleModel: json["ScaleModel"],
        scaleSn: json["ScaleSn"],
        settleAccountTimes: json["SettleAccountTimes"],
        totalCount: json["TotalCount"],
        payPrice: json["PayPrice"],
        totalPrice: json["TotalPrice"],
        taxKind: json["TaxKind"] == "0"
            ? "Off"
            : json["TaxKind"] == "1"
                ? "Include"
                : json["TaxKind"] == "1"
                    ? "Exclude"
                    : json["TaxKind"],
        createdAt: DateTime.parse(json["CreatedAt"]).toLocal(),
      );
}
