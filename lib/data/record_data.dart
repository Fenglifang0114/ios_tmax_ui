class GetScaleRecords {
  List<WeightRecords>? weightRecords;
  GetScaleRecords({this.weightRecords});

  factory GetScaleRecords.fromJson(List<dynamic> parsedJson) {
    List<WeightRecords> scaleDataList = <WeightRecords>[];
    scaleDataList = parsedJson.map((i) => WeightRecords.fromJson(i)).toList();

    return GetScaleRecords(weightRecords: scaleDataList);
  }
}

GetScaleRecords myGetScaleRecords = GetScaleRecords(weightRecords: []);

class WeightRecords {
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
  String? scaleName;
  String? createdAt;

  WeightRecords({
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
    this.scaleName,
    this.createdAt,
  });

  WeightRecords.fromJson(Map<String, dynamic> json) {
    recId = json['RecId'];
    id = json['Id'];
    scaleModel = json['ScaleModel'];
    scaleSn = json['ScaleSn'];
    plu = json['Plu'];
    productCode = json['ProductCode'];
    itemCode = json['ItemCode'];
    category = json['Category'];
    productName = json['ProductName'];
    generalUnit = json['GeneralUnit'];
    taxType = json['TaxType'];
    price = json['Price'];
    unitWeight = json['UnitWeight'];
    pretare = json['Pretare'];
    limitHigh = json['LimitHigh'];
    limitLow = json['LimitLow'];
    weight = json['Weight'];
    weightUnit = json['WeightUnit'];
    userNo = json['UserNo'];
    userName = json['UserName'];
    scaleName = json['ScaleName'];
    createdAt = json['CreatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RecId'] = recId;
    data['Id'] = id;
    data['ScaleModel'] = scaleModel;
    data['ScaleSn'] = scaleSn;
    data['Plu'] = plu;
    data['ProductCode'] = productCode;
    data['ItemCode'] = itemCode;
    data['Category'] = category;
    data['ProductName'] = productName;
    data['GeneralUnit'] = generalUnit;
    data['TaxType'] = taxType;
    data['Price'] = price;
    data['UnitWeight'] = unitWeight;
    data['Pretare'] = pretare;
    data['LimitHigh'] = limitHigh;
    data['LimitLow'] = limitLow;
    data['Weight'] = weight;
    data['WeightUnit'] = weightUnit;
    data['UserNo'] = userNo;
    data['UserName'] = userName;
    data['ScaleName'] = scaleName;
    data['CreatedAt'] = createdAt;
    return data;
  }
}

class AddScaleRecord {
  int? scaleId;
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
  String? scaleName;
  String? scaleMode;

  AddScaleRecord({
    this.scaleId,
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
    this.scaleMode,
  });

  AddScaleRecord.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    id = json['Id'];
    scaleModel = json['ScaleModel'];
    scaleSn = json['ScaleSn'];
    plu = json['Plu'];
    productCode = json['ProductCode'];
    itemCode = json['ItemCode'];
    category = json['Category'];
    productName = json['ProductName'];
    generalUnit = json['GeneralUnit'];
    taxType = json['TaxType'];
    price = json['Price'];
    unitWeight = json['UnitWeight'];
    pretare = json['Pretare'];
    limitHigh = json['LimitHigh'];
    limitLow = json['LimitLow'];
    weight = json['Weight'];
    weightUnit = json['WeightUnit'];
    userNo = json['UserNo'];
    userName = json['UserName'];
    scaleName = json['ScaleName'];
    scaleMode = json['ScaleMode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleId'] = scaleId;
    data['Id'] = id;
    data['ScaleModel'] = scaleModel;
    data['ScaleSn'] = scaleSn;
    data['Plu'] = plu;
    data['ProductCode'] = productCode;
    data['ItemCode'] = itemCode;
    data['Category'] = category;
    data['ProductName'] = productName;
    data['GeneralUnit'] = generalUnit;
    data['TaxType'] = taxType;
    data['Price'] = price;
    data['UnitWeight'] = unitWeight;
    data['Pretare'] = pretare;
    data['LimitHigh'] = limitHigh;
    data['LimitLow'] = limitLow;
    data['Weight'] = weight;
    data['WeightUnit'] = weightUnit;
    data['UserNo'] = userNo;
    data['UserName'] = userName;
    data['ScaleName'] = scaleName;
    data['ScaleMode'] = scaleMode;

    return data;
  }
}

AddScaleRecord myAddScaleRecord = AddScaleRecord();

class DeleteRec {
  int? recId;

  DeleteRec({this.recId});

  DeleteRec.fromJson(Map<String, dynamic> json) {
    recId = json['RecId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RecId'] = recId;
    return data;
  }
}

DeleteRec myDeleteRec = DeleteRec();
