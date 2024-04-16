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

ScaleInfoFromScale myScaleInfoFromScale = ScaleInfoFromScale(
  '',
  '',
  '',
  [],
);
