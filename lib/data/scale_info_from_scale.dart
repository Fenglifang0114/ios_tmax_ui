class ScaleInfoFromScale {
  String? scaleSn;
  String? modelName;
  String? scaleName;
  List<String>? addrInfos;

  ScaleInfoFromScale(
      this.scaleSn, this.modelName, this.scaleName, this.addrInfos);

  ScaleInfoFromScale.fromJson(Map<String, dynamic> json) {
    scaleSn = json['ScaleSn'];
    modelName = json['ModelName'];
    scaleName = json['ScaleName'];
    if (json['AddrInfos'] != null) {
      addrInfos = <String>[];
      json['AddrInfos'].forEach((v) {
        addrInfos!.add(v);
      });
    }
  }
}

class FactoryInfoFromScale {
  String? scaleSn;
  String? modelName;

  FactoryInfoFromScale(this.scaleSn, this.modelName);

  FactoryInfoFromScale.fromJson(Map<String, dynamic> json) {
    scaleSn = json['ScaleSn'];
    modelName = json['ModelName'];
  }
}

FactoryInfoFromScale myFactoryInfoFromScale = FactoryInfoFromScale('', '');
FactoryInfoFromScale myComScaleSn = FactoryInfoFromScale('', '');

class OnlineInfo {
  int? scaleId;
  FactoryInfoFromScale? factInfo;

  OnlineInfo(this.scaleId, this.factInfo);

  OnlineInfo.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    factInfo = json['FactInfo'];
  }
}

OnlineInfo myOnlineInfo = OnlineInfo(0, FactoryInfoFromScale('', ''));
