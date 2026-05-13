/*
RecWt 计价模式数据记录
*/

class RecPrice {
  int? recId;
  String? productName;
  double? weightNet;
  String? weightUnit;
  double? unitPrice;
  double? totalPrice;

  RecPrice(this.recId, this.productName, this.weightNet, this.weightUnit,
      this.unitPrice, this.totalPrice);

  RecPrice.fromJson(Map<String, dynamic> json) {
    recId = json['recId'];
    productName = json['productName'];
    weightNet = json['weightNet'];
    weightUnit = json['weightUnit'];
    unitPrice = json['unitPrice'];
    totalPrice = json['totalPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recId'] = recId;
    data['productName'] = productName;
    data['weightNet'] = weightNet;
    data['weightUnit'] = weightUnit;
    data['unitPrice'] = unitPrice;
    data['totalPrice'] = totalPrice;
    return data;
  }
}

RecPrice myRecPrice = RecPrice(0, "", 0.0, "", 0.0, 0.0);
