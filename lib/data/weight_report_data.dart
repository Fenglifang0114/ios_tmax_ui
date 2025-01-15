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
  'Date Time': ReportShowName('Date Time', true),
  'PLU': ReportShowName('PLU', true),
  'Product Code': ReportShowName('Product Code', false),
  'Item Code': ReportShowName('Item Code', false),
  'PLU Name': ReportShowName('PLU Name', true),
  'Price': ReportShowName('Price', false),
  'GeneralUnit': ReportShowName('GeneralUnit', false),
  'TaxType': ReportShowName('TaxType', false),
  'UnitWeight': ReportShowName('UnitWeight', false),
  'LimitHigh': ReportShowName('LimitHigh', false),
  'LimitLow': ReportShowName('LimitLow', false),
  'Weight': ReportShowName('Weight', true),
  'Weight Unit': ReportShowName('Weight Unit', true),
  'Pretare': ReportShowName('Pretare', false),
  'User NO.': ReportShowName('User NO.', false),
  'User Name': ReportShowName('User Name', true),
  'Scale Name': ReportShowName('Scale Name', true),
};

class ReportShowName {
  String showName;
  bool isSelect;
  ReportShowName(this.showName, this.isSelect);
}

// ReportFields myReportFields = ReportFields([]);
