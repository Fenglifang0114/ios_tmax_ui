import 'package:t_max/data/language.dart';

class WeightReportData {
  WeightReportData(
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
    this.scaleName,
    this.createdAt,
  );
  final String id;
  final String scaleModel;
  final String scaleSn;
  final String plu;
  final String productCode;
  final String itemCode;
  final String category;
  final String productName;
  final String generalUnit;
  final String taxType;
  final String price;
  final String unitWeight;
  final String pretare;
  final String limitHigh;
  final String limitLow;
  final String weight;
  final String weightUnit;
  final String userNo;
  final String userName;
  final String scaleName;
  final String createdAt;
}

WeightReportData myWeightReportData = WeightReportData('', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '');

class ReportFields {
  List<String> filedsList;
  ReportFields(this.filedsList);
}

class ReportShowName {
  String showName;
  bool isSelect;
  ReportShowName(this.showName, this.isSelect);
}

List<String> mySelFields() {
  List<String> selFields = [];
  for (var item in myReportFeildsMap.keys) {
    if ((myReportFeildsMap[item] ?? false)) {
      selFields.add(item);
    }
  }
  return selFields;
}

Map<String, String> mySelMap() {
  Map<String, String> mySelMap = {};
  for (var item in myReportFeildsMap.keys) {
    mySelMap[item] = getRptTitleName(item);
  }

  return mySelMap;
}

String getRptTitleName(String rptName) {
  switch (rptName) {
    case 'Id':
      return 'Id';
    case 'Date Time':
      return (localizedStrings?.gRptDateTime ?? "gRptDateTime");
    case 'PLU':
      return 'PLU';
    case 'Product Code':
      return (localizedStrings?.gPluPluCode ?? "gPluPluCode");
    case 'Item Code':
      return (localizedStrings?.gPluItemCode ?? "gPluItemCode");
    case 'PLU Name':
      return (localizedStrings?.gPluPluName ?? "gPluPluName");
    case 'Price':
      return (localizedStrings?.gPluPrice ?? "gPluPrice");
    case 'GeneralUnit':
      return (localizedStrings?.gPluWgtUnit ?? "gPluWgtUnit");
    case 'TaxType':
      return (localizedStrings?.gPluTaxType ?? "gPluTaxType");
    case 'UnitWeight':
      return (localizedStrings?.gPluUnitWgt ?? "gPluUnitWgt");
    case 'LimitHigh':
      return (localizedStrings?.gPluLimitHigh ?? "gPluLimitHigh");
    case 'LimitLow':
      return (localizedStrings?.gPluLimitLow ?? "gPluLimitLow");
    case 'Weight':
      return (localizedStrings?.gRptWeight ?? "gRptWeight");
    case 'Weight Unit':
      return (localizedStrings?.gRptWeightUnit ?? "gRptWeightUnit");
    case 'Pretare':
      return (localizedStrings?.gPluPretare ?? "gPluPretare");
    case 'User Name':
      return (localizedStrings?.operator ?? "operator");
    case 'Scale Name':
      return (localizedStrings?.gScaleName ?? "gScaleName");
    case 'Category':
      return (localizedStrings?.gPluCategory ?? "gPluCategory");
  }
  return rptName;
}

Map<String, bool> myReportFeildsMap = {
  'Id': true,
  'Date Time': true,
  'PLU': true,
  'Product Code': false,
  'Item Code': false,
  'PLU Name': true,
  'Price': false,
  'GeneralUnit': false,
  'TaxType': false,
  'UnitWeight': false,
  'LimitHigh': false,
  'LimitLow': false,
  'Weight': true,
  'Weight Unit': true,
  'Pretare': false,
  'User Name': true,
  'Scale Name': true,
};

// ReportFields myReportFields = ReportFields([]);
