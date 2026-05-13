class RecCount {
  int? recId;
  String? productName;
  double? unitWeight;
  double? weightNet;
  String? weightUnit;
  int? weightTare;

  RecCount(this.recId, this.productName, this.unitWeight, this.weightNet,
      this.weightUnit, this.weightTare);

  RecCount.fromJson(Map<String, dynamic> json) {
    recId = json['recId'];
    productName = json['productName'];
    unitWeight = json['unitWeight '];
    weightNet = json['weightNet'];
    weightUnit = json['weightUnit'];
    weightTare = json['weightTare'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recId'] = recId;
    data['productName'] = productName;
    data['unitWeight '] = unitWeight;
    data['weightNet'] = weightNet;
    data['weightUnit'] = weightUnit;
    data['weightTare'] = weightTare;
    return data;
  }
}

RecCount myRecCount = RecCount(0, "", 0.00, 0.00, "", 0);
