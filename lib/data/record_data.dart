// class GetScaleRecords {
//   List<WeightRecords>? weightRecords;
//   GetScaleRecords({this.weightRecords});

//   factory GetScaleRecords.fromJson(List<dynamic> parsedJson) {
//     List<WeightRecords> scaleDataList = <WeightRecords>[];
//     scaleDataList = parsedJson.map((i) => WeightRecords.fromJson(i)).toList();

//     return GetScaleRecords(weightRecords: scaleDataList);
//   }
// }

// GetScaleRecords myGetScaleRecords = GetScaleRecords(weightRecords: []);

// class WeightRecords {
//   int? recId;
//   String? scaleModel;
//   String? scaleSn;
//   String? product;
//   String? weight;
//   String? price;
//   String? createdAt;

//   WeightRecords(
//       {this.recId,
//       this.scaleModel,
//       this.scaleSn,
//       this.product,
//       this.weight,
//       this.price,
//       this.createdAt});

//   WeightRecords.fromJson(Map<String, dynamic> json) {
//     recId = json['RecId'];
//     scaleModel = json['ScaleModel'];
//     scaleSn = json['ScaleSn'];
//     product = json['Product'];
//     weight = json['Weight'];
//     price = json['Price'];
//     createdAt = json['CreatedAt'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['RecId'] = this.recId;
//     data['ScaleModel'] = this.scaleModel;
//     data['ScaleSn'] = this.scaleSn;
//     data['Product'] = this.product;
//     data['Weight'] = this.weight;
//     data['Price'] = this.price;
//     data['CreatedAt'] = this.createdAt;
//     return data;
//   }
// }

// class AddScaleRecord {
//   int? scaleId;
//   String? product;
//   String? weight;
//   String? price;

//   AddScaleRecord({this.scaleId, this.product, this.weight, this.price});

//   AddScaleRecord.fromJson(Map<String, dynamic> json) {
//     scaleId = json['ScaleId'];
//     product = json['Product'];
//     weight = json['Weight'];
//     price = json['Price'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['ScaleId'] = this.scaleId;
//     data['Product'] = this.product;
//     data['Weight'] = this.weight;
//     data['Price'] = this.price;
//     return data;
//   }
// }

// AddScaleRecord myAddScaleRecord = AddScaleRecord();

// class DeleteRec {
//   int? recId;

//   DeleteRec({this.recId});

//   DeleteRec.fromJson(Map<String, dynamic> json) {
//     recId = json['RecId'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['RecId'] = this.recId;
//     return data;
//   }
// }

// DeleteRec myDeleteRec = DeleteRec();
