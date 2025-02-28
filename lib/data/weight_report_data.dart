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

Map<String, ReportShowName> myReportFeildsMap = {
  'Id': ReportShowName('Id', true),
  'Date Time': ReportShowName(localizedStrings.gRptDateTime, true),
  'PLU': ReportShowName('PLU', true),
  'Product Code': ReportShowName(localizedStrings.gPluPluCode, false),
  'Item Code': ReportShowName(localizedStrings.gPluItemCode, false),
  'PLU Name': ReportShowName(localizedStrings.gPluPluName, true),
  'Price': ReportShowName(localizedStrings.gPluPrice, false),
  'GeneralUnit': ReportShowName(localizedStrings.gPluWgtUnit, false),
  'TaxType': ReportShowName(localizedStrings.gPluTaxType, false),
  'UnitWeight': ReportShowName(localizedStrings.gPluUnitWgt, false),
  'LimitHigh': ReportShowName(localizedStrings.gPluLimitHigh, false),
  'LimitLow': ReportShowName(localizedStrings.gPluLimitLow, false),
  'Weight': ReportShowName(localizedStrings.gRptWeight, true),
  'Weight Unit': ReportShowName(localizedStrings.gRptWeightUnit, true),
  'Pretare': ReportShowName(localizedStrings.gPluPretare, false),
  // 'User NO.': ReportShowName('User NO.', false),
  // 'User Name': ReportShowName('User Name', true),
  'Scale Name': ReportShowName(localizedStrings.gScaleName, true),
};

class ReportShowName {
  String showName;
  bool isSelect;
  ReportShowName(this.showName, this.isSelect);
}

// ReportFields myReportFields = ReportFields([]);

// 更新 myReportFeildsMap 的函数
void updateMyReportFeildsMap() {
  myReportFeildsMap.updateAll((key, value) {
    switch (key) {
      case 'Product Code':
        value.showName = localizedStrings.gPluPluCode;
        break;
      case 'Item Code':
        value.showName = localizedStrings.gPluItemCode;
        break;
      case 'PLU Name':
        value.showName = localizedStrings.gPluPluName;
        break;
      case 'Price':
        value.showName = localizedStrings.gPluPrice;
        break;
      case 'GeneralUnit':
        value.showName = localizedStrings.gPluWgtUnit;
        break;
      case 'TaxType':
        value.showName = localizedStrings.gPluTaxType;
        break;
      case 'UnitWeight':
        value.showName = localizedStrings.gPluUnitWgt;
        break;
      case 'LimitHigh':
        value.showName = localizedStrings.gPluLimitHigh;
        break;
      case 'LimitLow':
        value.showName = localizedStrings.gPluLimitLow;
        break;
      case 'Pretare':
        value.showName = localizedStrings.gPluPretare;
        break;
      case 'Scale Name':
        value.showName = localizedStrings.gScaleName;
        break;
    }
    return value;
  });
}
