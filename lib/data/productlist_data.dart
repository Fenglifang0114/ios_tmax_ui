class ProductRecList {
  List<ProductRecInfo>? productRecInfo;

  ProductRecList({this.productRecInfo});

  factory ProductRecList.fromJson(List<dynamic> parsedJson) {
    List<ProductRecInfo> scaleDataList = <ProductRecInfo>[];
    scaleDataList = parsedJson.map((i) => ProductRecInfo.fromJson(i)).toList();

    return ProductRecList(productRecInfo: scaleDataList);
  }
}

ProductRecList myProductRecList = ProductRecList();

class ProductRecInfo {
  int? recId;
  String? id;
  String? product;
  bool? withPretare;
  String? pretare;
  String? remarks;
  String? createdAt;

  ProductRecInfo(
      {this.recId,
      this.id,
      this.product,
      this.withPretare,
      this.pretare,
      this.remarks,
      this.createdAt});

  ProductRecInfo.fromJson(Map<String, dynamic> json) {
    recId = json['RecId'];
    id = json['Id'];
    product = json['Product'];
    withPretare = json['WithPretare'];
    pretare = json['Pretare'];
    remarks = json['Remarks'];
    createdAt = json['CreatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RecId'] = recId;
    data['Id'] = id;
    data['Product'] = product;
    data['WithPretare'] = withPretare;
    data['Pretare'] = pretare;
    data['Remarks'] = remarks;
    data['CreatedAt'] = createdAt;
    return data;
  }
}

ProductRecInfo myProductRecInfo = ProductRecInfo();
