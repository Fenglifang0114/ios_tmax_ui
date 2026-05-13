class HeaderFooterData {
  int id;
  String value;
  HeaderFooterData(
    this.id,
    this.value,
  );
  HeaderFooterData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        value = json['value'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['value'] = value;
    return data;
  }
}

class HeaderFooterList {
  List<HeaderFooterData> listData;
  HeaderFooterList(this.listData);
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> jsonData =
        listData.map((data) => data.toJson()).toList();
    return {'listData': jsonData};
  }
}

HeaderFooterList myHeaderFooterList = HeaderFooterList([]);
