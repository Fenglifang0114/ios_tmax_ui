class SelectedControl {
  int selectid;
  bool isSelect;
  SelectedControl(this.selectid, this.isSelect);
  SelectedControl.fromJson(Map<String, dynamic> json)
      : selectid = json['selectid'],
        isSelect = json['isSelect'];

  Map<String, dynamic> toJson() {
    return {
      'selectid': selectid,
      'isSelect': isSelect,
    };
  }
}

SelectedControl mySelectedControl = SelectedControl(0, true);

class ReceiptSelCtl {
  int selectid;
  bool isSelect;
  ReceiptSelCtl(this.selectid, this.isSelect);
  ReceiptSelCtl.fromJson(Map<String, dynamic> json)
      : selectid = json['selectid'],
        isSelect = json['isSelect'];

  Map<String, dynamic> toJson() {
    return {
      'selectid': selectid,
      'isSelect': isSelect,
    };
  }
}

ReceiptSelCtl myReceiptSelCtl = ReceiptSelCtl(0, true);
