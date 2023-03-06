import 'package:t_max/data/comscaleinfo_data.dart';

class ScaleTotalInfo {
  List<ScaleDataList>? scaleDataList;

  ScaleTotalInfo({this.scaleDataList});

  factory ScaleTotalInfo.fromJson(List<dynamic> parsedJson) {
    List<ScaleDataList> scaleDataList = <ScaleDataList>[];
    scaleDataList = parsedJson.map((i) => ScaleDataList.fromJson(i)).toList();

    return ScaleTotalInfo(scaleDataList: scaleDataList);
  }
}

ScaleTotalInfo myScaleTotalInfo = ScaleTotalInfo(scaleDataList: []);

class ScaleDataList {
  bool? isOnline;
  String? scaleModel;
  String? scaleSn;
  int? scaleId;
  int? tMedia;
  MediaInfo? mediaInfo;

  ScaleDataList(
      {this.isOnline,
      this.scaleModel,
      this.scaleSn,
      this.scaleId,
      this.tMedia,
      this.mediaInfo});

  factory ScaleDataList.fromJson(Map<String, dynamic> json) {
    return ScaleDataList(
      isOnline: json['IsOnline'],
      scaleModel: json['ScaleModel'],
      scaleSn: json['ScaleSn'],
      scaleId: json['ScaleId'],
      tMedia: json['TMedia'],
      mediaInfo: json['MediaConf'] != null
          ? MediaInfo.fromJson(json['MediaConf'])
          : null,
    );
  }
}

class MediaInfo {
  int? type;
  String? mediaInfoJson;

  MediaInfo({this.type, this.mediaInfoJson});

  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(
      type: json['Type'],
      mediaInfoJson: json['MediaInfoJson'],
    );
  }
}

class CurrentPort {
  String? devPath;
  int? baud;
  int? dataBits;
  int? stopBits;
  int? parity;

  CurrentPort(
      {this.devPath, this.baud, this.dataBits, this.stopBits, this.parity});

  CurrentPort.fromJson(Map<String, dynamic> json) {
    devPath = json['DevPath'];
    baud = json['Baud'];
    dataBits = json['DataBits'];
    stopBits = json['StopBits'];
    parity = json['Parity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DevPath'] = this.devPath;
    data['Baud'] = this.baud;
    data['DataBits'] = this.dataBits;
    data['StopBits'] = this.stopBits;
    data['Parity'] = this.parity;
    return data;
  }
}

class MediaInfoJson {
  String? devPath;
  int? baud;
  int? dataBits;
  int? stopBits;
  int? parity;

  MediaInfoJson(
      {this.devPath, this.baud, this.dataBits, this.stopBits, this.parity});
  factory MediaInfoJson.fromJson(Map<String, dynamic> json) {
    return MediaInfoJson(
      devPath: json['DevPath'],
      baud: json['Baud'],
      dataBits: json['DataBits'],
      stopBits: json['StopBits'],
      parity: json['Parity'],
    );
  }
}

MediaInfoJson myMediaInfoJson = MediaInfoJson();
