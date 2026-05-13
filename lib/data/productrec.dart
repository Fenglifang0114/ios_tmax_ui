class ProductRec {
  String id;
  String product;
  bool withPretare;
  String pretare;
  String remarks;

  ProductRec(
      this.id, this.product, this.withPretare, this.pretare, this.remarks);

  ProductRec.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        product = json['Product'],
        withPretare = json['WithPretare'],
        pretare = json['Pretare'],
        remarks = json['Remarks'];

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Product': product,
      'WithPretare': withPretare,
      'Pretare': pretare,
      'Remarks': remarks,
    };
  }
}

ProductRec myProductRec = ProductRec("", "", false, "", '');

class ProductRecEdit {
  int recId;
  String id;
  String product;
  bool withPretare;
  String pretare;
  String remarks;

  ProductRecEdit(this.recId, this.id, this.product, this.withPretare,
      this.pretare, this.remarks);

  ProductRecEdit.fromJson(Map<String, dynamic> json)
      : recId = json['RecId'],
        id = json['Id'],
        product = json['Product'],
        withPretare = json['WithPretare'],
        pretare = json['Pretare'],
        remarks = json['Remarks'];

  Map<String, dynamic> toJson() {
    return {
      'RecId': recId,
      'Id': id,
      'Product': product,
      'WithPretare': withPretare,
      'Pretare': pretare,
      'Remarks': remarks,
    };
  }
}

ProductRecEdit myProductRecEdit = ProductRecEdit(0, "", "", false, "", '');

class ProductRecDel {
  int recId;
  ProductRecDel(this.recId);
  ProductRecDel.fromJson(Map<String, dynamic> json) : recId = json['RecId'];

  Map<String, dynamic> toJson() {
    return {
      'RecId': recId,
    };
  }
}

ProductRecDel myProductRecDel = ProductRecDel(0);
