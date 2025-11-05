class BarCodeRowData {
  String type;
  String content;
  String defaultvalue;
  String alignment;
  int maxlength;
  bool canDelete;

  BarCodeRowData(this.type, this.content, this.defaultvalue, this.alignment,
      this.maxlength,
      {this.canDelete = true});

  BarCodeRowData.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        content = json['content'],
        defaultvalue = json['defaultvalue'],
        alignment = json['alignment'],
        maxlength = json['maxlength'],
        canDelete = json['canDelete'];

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      'defaultvalue': defaultvalue,
      'alignment': alignment,
      'maxlength': maxlength,
      'canDelete': canDelete,
    };
  }
}

BarCodeRowData myBarCodeRowData = BarCodeRowData(
  'TEXT',
  '',
  '',
  '',
  7,
);

class BarCodeRowDataInfo {
  List<BarCodeRowData> barCodeRowDataList = [];
  String barCodeName = '';
  String barCodeType = '';
  bool? isExpand = false;

  BarCodeRowDataInfo(
      this.barCodeRowDataList, this.barCodeName, this.barCodeType);
  BarCodeRowDataInfo.fromJson(Map<String, dynamic> json) {
    barCodeName = json['BarCodeName'];
    barCodeType = json['BarCodeType'];
    isExpand = json['isExpand'];
    if (json['BarCodeRowDataList'] != null) {
      var list = json['BarCodeRowDataList'] as List;
      List<BarCodeRowData> barcodelist =
          list.map((i) => BarCodeRowData.fromJson(i)).toList();
      barCodeRowDataList = barcodelist;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BarCodeName'] = barCodeName;
    data['BarCodeType'] = barCodeType;
    data['isExpand'] = isExpand;
    data['BarCodeRowDataList'] =
        barCodeRowDataList.map((v) => v.toJson()).toList();
    return data;
  }
}

BarCodeRowDataInfo myBarCodeRowDataList = BarCodeRowDataInfo([], '', '');

class BarCodeListList {
  List<BarCodeRowDataInfo> barCodeListList = [];

  BarCodeListList(this.barCodeListList);
  // BarCodeListList.fromJson(Map<String, dynamic> json) {
  //   if (json['barCodeListList'] != null) {
  //     barCodeListList = <BarCodeListList>[].cast<BarCodeRowDataList>();
  //     json['barCodeListList'].forEach((v) {
  //       barCodeListList.add(BarCodeListList.fromJson(v) as BarCodeRowDataList);
  //     });
  //   }
  // }

  factory BarCodeListList.fromJson(List<dynamic> parsedJson) {
    List<BarCodeRowDataInfo> barCodeListList = <BarCodeRowDataInfo>[];
    barCodeListList =
        parsedJson.map((i) => BarCodeRowDataInfo.fromJson(i)).toList();
    return BarCodeListList(barCodeListList);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BarCodeListList'] = barCodeListList.map((v) => v.toJson()).toList();
    return data;
  }
}

BarCodeListList myBarCodeListList = BarCodeListList([]);

class SavedBarcodeName {
  List<String> savedBarcodeName;
  SavedBarcodeName(this.savedBarcodeName);
}

SavedBarcodeName mySavedBarcodeName = SavedBarcodeName([]);

class SavedQrcodeName {
  List<String> savedQrcodeName;
  SavedQrcodeName(this.savedQrcodeName);
}

SavedQrcodeName mySavedQrcodeName = SavedQrcodeName([]);
