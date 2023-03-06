class Comportdata {
  String modelName;
  String scaSn;
  String scdescription;
  int id;
  int mediaType;
  String portName;
  int baud;
  int dataBits;
  String parity;
  int stopbits;

  Comportdata(
      this.modelName,
      this.scaSn,
      this.scdescription,
      this.id,
      this.mediaType,
      this.portName,
      this.baud,
      this.dataBits,
      this.parity,
      this.stopbits);
  Comportdata.fromJson(Map<String, dynamic> json)
      : modelName = json['modelName'],
        scaSn = json['scaSn'],
        scdescription = json['scdescription'],
        id = json['id'],
        mediaType = json['mediaType'],
        portName = json['portName'],
        baud = json['baud'],
        dataBits = json['dataBits'],
        parity = json['parity'],
        stopbits = json['stopbits'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['modelName'] = modelName;
    data['scaSn'] = scaSn;
    data['scdescription'] = scdescription;
    data['id'] = id;
    data['mediaType'] = mediaType;
    data['portName'] = portName;
    data['baud'] = baud;
    data['dataBits'] = dataBits;
    data['parity'] = parity;
    data['stopbits'] = stopbits;
    return data;
  }
}

Comportdata myComportdata = Comportdata("", "", "", 0, 0, "", 0, 0, "", 0);
