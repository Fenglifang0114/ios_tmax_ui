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

  WeightRecords(
      {this.recId,
      this.scaleModel,
      this.scaleSn,
      this.product,
      this.weight,
      this.price,
      this.createdAt});

  WeightRecords.fromJson(Map<String, dynamic> json) {
    recId = json['RecId'];
    scaleModel = json['ScaleModel'];
    scaleSn = json['ScaleSn'];
    product = json['Product'];
    weight = json['Weight'];
    price = json['Price'];
    createdAt = json['CreatedAt'];
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
    return data;
  }
}

class AddScaleRecord {
  int? scaleId;
  String? product;
  String? weight;
  String? price;

  AddScaleRecord({this.scaleId, this.product, this.weight, this.price});

  AddScaleRecord.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    product = json['Product'];
    weight = json['Weight'];
    price = json['Price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleId'] = scaleId;
    data['Product'] = product;
    data['Weight'] = weight;
    data['Price'] = price;
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
