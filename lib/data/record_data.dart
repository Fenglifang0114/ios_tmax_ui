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
  String? scaleModel;
  String? scaleSn;
  String? product;
  String? weight;
  String? price;
  String? createdAt;
  String? pluNo;
  String? pluRemarks;
  String? weightUnit;
  String? pretare;
  String? userNo;
  String? userName;
  String? userRemarks;

  WeightRecords(
      {this.recId,
      this.scaleModel,
      this.scaleSn,
      this.product,
      this.weight,
      this.price,
      this.createdAt,
      this.pluNo,
      this.pluRemarks,
      this.weightUnit,
      this.pretare,
      this.userNo,
      this.userName,
      this.userRemarks});

  WeightRecords.fromJson(Map<String, dynamic> json) {
    recId = json['RecId'];
    scaleModel = json['ScaleModel'];
    scaleSn = json['ScaleSn'];
    product = json['Product'];
    weight = json['Weight'];
    price = json['Price'];
    createdAt = json['CreatedAt'];
    pluNo = json['PluNo'];
    pluRemarks = json['PluRemarks'];
    weightUnit = json['WeightUnit'];
    pretare = json['Pretare'];
    userNo = json['UserNo'];
    userName = json['UserName'];
    userRemarks = json['UserRemarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RecId'] = recId;
    data['ScaleModel'] = scaleModel;
    data['ScaleSn'] = scaleSn;
    data['Product'] = product;
    data['Weight'] = weight;
    data['Price'] = price;
    data['CreatedAt'] = createdAt;
    data['PluNo'] = pluNo;
    data['PluRemarks'] = pluRemarks;
    data['WeightUnit'] = weightUnit;
    data['Pretare'] = pretare;
    data['UserNo'] = userNo;
    data['UserName'] = userName;
    data['UserRemarks'] = userRemarks;
    return data;
  }
}

class AddScaleRecord {
  int? scaleId;
  String? product;
  String? weight;
  String? price;
  String? pluNo;
  String? pluRemarks;
  String? weightUnit;
  String? pretare;
  String? userNo;
  String? userName;
  String? userRemarks;
  String? scaleMode;

  AddScaleRecord(
      {this.scaleId,
      this.product,
      this.weight,
      this.price,
      this.pluNo,
      this.pluRemarks,
      this.weightUnit,
      this.pretare,
      this.userNo,
      this.userName,
      this.userRemarks,
      this.scaleMode});

  AddScaleRecord.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    product = json['Product'];
    weight = json['Weight'];
    pluNo = json['PluNo'];
    pluRemarks = json['PluRemarks'];
    weightUnit = json['WeightUnit'];
    pretare = json['Pretare'];
    userNo = json['UserNo'];
    userName = json['UserName'];
    userRemarks = json['UserRemarks'];
    scaleMode = json['ScaleMode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleId'] = scaleId;
    data['Product'] = product;
    data['Weight'] = weight;
    data['Price'] = price;
    data['PluNo'] = pluNo;
    data['PluRemarks'] = pluRemarks;
    data['WeightUnit'] = weightUnit;
    data['Pretare'] = pretare;
    data['UserNo'] = userNo;
    data['UserName'] = userName;
    data['UserRemarks'] = userRemarks;
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
