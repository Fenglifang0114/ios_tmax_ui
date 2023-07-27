class Devicedata {
  String name;
  String type;

  String scaleID;
  String scaleSn;
  int mediaType;
  Devicedata(this.name, this.type, this.scaleID, this.scaleSn, this.mediaType);
  Devicedata.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        type = json['type'],
        scaleID = json['scaleID'],
        scaleSn = json['scaleSn'],
        mediaType = json['mediaType'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'scaleID': scaleID,
      'scaleSn': scaleSn,
      'mediaType': mediaType,
    };
  }
}

Devicedata myDevicedata = Devicedata("", "", "", "", 0);
