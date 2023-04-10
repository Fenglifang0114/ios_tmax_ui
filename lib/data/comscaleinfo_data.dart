class ComScaleInfoList {
  int scaleId;
  int tMedia;
  bool isOnline;
  String portName;
  int baudRate;
  int dataBits;
  int parity;
  int stopBits;
  String scaleModel;
  String scaleSn;

  ComScaleInfoList(
      this.scaleId,
      this.tMedia,
      this.isOnline,
      this.portName,
      this.baudRate,
      this.dataBits,
      this.parity,
      this.stopBits,
      this.scaleModel,
      this.scaleSn);

  ComScaleInfoList.fromJson(Map<String, dynamic> json)
      : scaleId = json['ScaleId'],
        tMedia = json['TMedia'],
        isOnline = json['IsOnline'],
        portName = json['PortName'],
        baudRate = json['BaudRate'],
        dataBits = json['DataBits'],
        parity = json['Parity'],
        stopBits = json['StopBits'],
        scaleModel = json['ScaleModel'],
        scaleSn = json['scaleSn'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleId'] = scaleId;
    data['TMedia'] = tMedia;
    data['IsOnline'] = isOnline;
    data['BaudRate'] = baudRate;
    data['DataBits'] = dataBits;
    data['Parity'] = parity;
    data['StopBits'] = stopBits;
    data['ScaleModel'] = scaleModel;
    data['scaleSn'] = scaleSn;

    return data;
  }
}

ComScaleInfoList myComScaleInfoList =
    ComScaleInfoList(1, 1, true, "", 1, 1, 1, 1, "", "");

class ComScaleList {
  late List<ComScaleInfoList> comScaleList;

  ComScaleList({required this.comScaleList});

  factory ComScaleList.fromJson(List<dynamic> parsedJson) {
    List<ComScaleInfoList> scaleDataList = <ComScaleInfoList>[];
    scaleDataList =
        parsedJson.map((i) => ComScaleInfoList.fromJson(i)).toList();

    return ComScaleList(comScaleList: scaleDataList);
  }
}

ComScaleList myComScaleList = ComScaleList(comScaleList: []);
