class ScaleInfoFromScale {
  String? scaleSn;
  String? modelName;
  List<String>? addrInfos;

  ScaleInfoFromScale({this.scaleSn, this.modelName, this.addrInfos});

  ScaleInfoFromScale.fromJson(Map<String, dynamic> json) {
    scaleSn = json['ScaleSn'];
    modelName = json['ModelName'];
    if (json['AddrInfos'] != null) {
      addrInfos = <String>[];
      json['AddrInfos'].forEach((v) {
        addrInfos!.add(v);
      });
    }
  }
}

ScaleInfoFromScale myScaleInfoFromScale = ScaleInfoFromScale();
