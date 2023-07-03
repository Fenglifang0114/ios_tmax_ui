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
