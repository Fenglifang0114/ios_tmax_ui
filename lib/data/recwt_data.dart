/*
RecWt 计重模式数据记录
*/

class RecWt {
  int? recId;
  String? productName;
  double? weightGross;
  double? weightNet;
  double? weightTare;
  String? weightUnit;

  RecWt(this.recId, this.productName, this.weightGross, this.weightNet,
      this.weightTare, this.weightUnit);

  RecWt.fromJson(Map<String, dynamic> json) {
    recId = json['recId'];
    productName = json['productName'];
    weightGross = json['weightGross '];
    weightNet = json['weightNet'];
    weightTare = json['weightTare'];
    weightUnit = json['weightUnit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recId'] = recId;
    data['productName'] = productName;
    data['weightGross '] = weightGross;
    data['weightNet'] = weightNet;
    data['weightTare'] = weightTare;
    data['weightUnit'] = weightUnit;
    return data;
  }
}

RecWt myRecWt = RecWt(
  0,
  "",
  0.0,
  0.0,
  0.0,
  "",
);
